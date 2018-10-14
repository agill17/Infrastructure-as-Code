package stub

import (
	"context"
	"encoding/base64"
	"fmt"
	"os"
	"time"

	"github.com/agill17/s3-operator/pkg/apis/amritgill/v1alpha1"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/operator-framework/operator-sdk/pkg/sdk"
	"github.com/sirupsen/logrus"
	"k8s.io/api/core/v1"
	apierrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func NewHandler() sdk.Handler {
	return &Handler{}
}

// What this is doing;
/*
	1. Operator get deployed in a central namespace
	2. Cr gets created in multiple namespaces
	3. Operator checks CR status ( timeUpdated and deployed )
	4. If timeUpdated == nil && deployed = false, then make aws calls
	5. Create IAM User if it does not exist
	6. Base64 encode the AccessKeyId in CR annotation for future use
	7. Create S3 bucket if it does not exist
	8. Update each CR Status ( timeUpdated -- time.format and deployed -- boolean )
	9. Create Kube Secret using IAM creds ( base64 encoded ) -- Outside of main condition check so this is auto-created if deleted by operator-sdk
	10. Check CR how often to verify existence of external resource and update CR statuses at each interval

	This way if bucket / IAM user gets deleted, the operator is able to auto-create the services again.
	However the check will be not dont every RESYNC_PERIOD, this will apply globally.
	Instead we fine-grain control how often to check for each CR.complex128

	TODO:
	if IAM User is re-created, need to update aws-creds secrets (done)

*/

const (
	accessKeyForNewSecret = "ACCESS_KEY"
	secretKeyForNewSecret = "SECRET_KEY"
)

type Handler struct {
}

func getSvcs(region string) (*s3.S3, *iam.IAM) {
	sess, _ := session.NewSession(&aws.Config{
		Region: aws.String(region)},
	)
	s3Client := s3.New(sess)
	iamClient := iam.New(sess)
	return s3Client, iamClient
}

func (h *Handler) Handle(ctx context.Context, event sdk.Event) error {
	objectStore := event.Object.(*v1alpha1.S3)
	ns := objectStore.GetNamespace()
	s3Client, iamClient := getSvcs(objectStore.S3Specs.Region)
	bucket := objectStore.S3Specs.BucketName
	region := objectStore.S3Specs.Region
	accessPolicy := objectStore.S3Specs.NewUser.Policy
	// secretName := objectStore.S3Specs.NewUser.SecretName
	iamUserName := ns
	metdataLabels := objectStore.ObjectMeta.GetLabels()
	if _, exists := metdataLabels["namespace"]; !exists {
		metdataLabels["namespace"] = ns
	}
	var err error

	//iamUser inputs
	iamUser := iamUserInput{
		iamClient:       iamClient,
		username:        iamUserName,
		accessPolicyArn: accessPolicy,
		namespace:       ns,
		objectStore:     objectStore,
	}

	// s3 inputs
	s3Input := s3Input{
		s3Svc:      s3Client,
		bucketName: bucket,
		bucketTags: metdataLabels,
		region:     region,
		namespace:  ns,
	}
	timeNullCheckVal := *new(time.Time)
	os.Setenv("AWS_REGION", region)
	timeDiffSinceLastCheck := int(time.Now().Sub(objectStore.Status.TimeUpdated).Minutes())

	// check initial cr status
	if objectStore.Status.TimeUpdated == timeNullCheckVal && iamUser.iamUserExists() {
		logrus.Errorf("IAM User - %v - already exists at initial run.. Cannot continue until user is deleted for NS: %v", iamUserName, ns)
	} else if (objectStore.Status.TimeUpdated == timeNullCheckVal) || (objectStore.Status.Deployed && timeDiffSinceLastCheck >= objectStore.S3Specs.ExistenceCheckAfterMins) {

		// create IAM user if it does not exists and get accessKey
		iamUser.createUserIfDoesNotExists()
		// Create Bucket if it does not exist
		s3Input.createBucketIfDoesNotExist()

		objectStore.Status.Deployed = true
		objectStore.Status.TimeUpdated = time.Now()
		err = sdk.Update(objectStore)
		errorCheck(err, func() {
			logrus.Errorf("Namespace: %v | Bucket: %v | Msg: Failed to update CR status %v", ns, bucket, err)
		})

	}

	deployIAMSecret(objectStore, metdataLabels)

	if event.Deleted {

		s3Input.deleteBucket()
		decodedAccessKey := encodeDecode(objectStore.Status.AccessKey, "decode")
		if objectStore.Status.AccessKey != "" {
			iamUser.deleteIamUser(decodedAccessKey)
		} else {
			logrus.Errorf("Namespace: %v | IAM Username: %v | Msg: CR does not have accessKeyId", ns, iamUserName)
			logrus.Errorf("Namespace: %v | IAM Username: %v | Msg: Please delete this user by hand!", ns, iamUserName)
		}

	}

	return nil

}

func deployIAMSecret(objectStore *v1alpha1.S3, metdataLabels map[string]string) {
	// create secret -- this will be picked after resync period for each CR deployed in a namespace

	defer updateSecretIfNeeded(objectStore)

	err := sdk.Create(secretObjSpec(objectStore))

	if err != nil && !apierrors.IsAlreadyExists(err) && !apierrors.IsForbidden(err) {
		logrus.Errorf("Failed to create Aws Secret : %v", err)
	}

}

func getSecret(objectStore *v1alpha1.S3) *v1.Secret {
	return &v1.Secret{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Secret",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      objectStore.S3Specs.NewUser.SecretName,
			Namespace: objectStore.GetNamespace(),
		},
	}
}

func secretObjSpec(crObj *v1alpha1.S3) *v1.Secret {
	o := true
	return &v1.Secret{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Secret",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      crObj.S3Specs.NewUser.SecretName,
			Namespace: crObj.GetNamespace(),
			Labels:    crObj.ObjectMeta.GetLabels(),
			OwnerReferences: []metav1.OwnerReference{{
				Name:               crObj.GetName(),
				APIVersion:         crObj.APIVersion,
				Kind:               crObj.Kind,
				UID:                crObj.GetUID(),
				BlockOwnerDeletion: &o,
				Controller:         &o,
			}},
		},
		Type: v1.SecretType("Opaque"),
		Data: map[string][]byte{
			accessKeyForNewSecret: []byte(encodeDecode(crObj.Status.AccessKey, "decode")),
			secretKeyForNewSecret: []byte(encodeDecode(crObj.Status.SecretKey, "decode")),
		},
	}
}

func updateSecretIfNeeded(objectStore *v1alpha1.S3) {

	secretObj := getSecret(objectStore)
	err := sdk.Get(secretObj)

	if !apierrors.IsNotFound(err) && !apierrors.IsForbidden(err) {
		deocdedAccessKeyFromSecret := fmt.Sprintf("%s", secretObj.Data[accessKeyForNewSecret])
		decodedAccessKeyFromCR := encodeDecode(objectStore.Status.AccessKey, "decode")

		if deocdedAccessKeyFromSecret != decodedAccessKeyFromCR {
			logrus.Warnf("Updating secret \"%v\" with new creds for namespace: %v", objectStore.S3Specs.NewUser.SecretName, objectStore.GetNamespace())
			err = sdk.Update(secretObjSpec(objectStore))
			errorCheck(err, func() { logrus.Errorf("ERROR updating secrets in namespace %v: %v", objectStore.GetNamespace(), err) })
		}
	}

}

func errorCheck(err error, block func()) error {
	if err != nil {
		block()
		return err
	}
	return nil
}

func encodeDecode(str, action string) string {
	var finalString string
	switch action {
	case "encode":
		finalString = base64.StdEncoding.EncodeToString([]byte(str))
		break
	case "decode":
		deocdedByte, _ := base64.StdEncoding.DecodeString(str)
		finalString = fmt.Sprintf("%s", deocdedByte)
	}

	return finalString
}
