package stub

import (
	"context"
	"encoding/base64"
	"fmt"
	"os"

	"github.com/agill17/s3-operator/pkg/apis/amritgill/v1alpha1"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/operator-framework/operator-sdk/pkg/sdk"
	"github.com/sirupsen/logrus"
	"k8s.io/api/core/v1"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func NewHandler() sdk.Handler {
	return &Handler{}
}

// NOTE:
/*
	b.c the handler runs in a loop, I had use this struct a way to store which ns was
	deployed with which IAM accessKey. Now why save the accessKey and not the IAM username?
	Well inorder to delete an IAM Username, we HAVE to delete the accessKey associated with that
	IAM user first, then delete the user using username. Each time the loop runs, the IAM username is resolved
	from the deployed CR ( aka the ns ), therefore I did not have to save the IAM username.
	If an IAM user is deleted, the NsAccessKey map is updated by deleteing that ns key from the map.
*/
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

	ns := objectStore.GetNamespace
	s3Client, iamClient := getSvcs(objectStore.S3Specs.Region)
	bucket := objectStore.S3Specs.BucketName
	region := objectStore.S3Specs.Region
	accessPolicy := objectStore.S3Specs.NewUser.Policy
	secretName := objectStore.S3Specs.NewUser.SecretName
	iamUserName := ns()

	metdataLabels := objectStore.ObjectMeta.GetLabels()
	if _, exists := metdataLabels["namespace"]; !exists {
		metdataLabels["namespace"] = ns()
	}

	os.Setenv("AWS_REGION", region)
	if objectStore.Status.Deployed != true {
		logrus.Infof("Namespace: %v | Bucket: %v | Msg: Creating Bucket ", ns(), bucket)

		// create new user if accessPolicy defined.
		// Use accessKeys to create new secret.
		if accessPolicy != "" {
			accessKey, secretKey := CreateIAMWithKeys(iamUserName, region, accessPolicy, ns(), iamClient)

			// store the AccessKey as a string b64-encoded in each Ns CR
			objectStore.Status.AccessKey = base64.StdEncoding.EncodeToString([]byte(accessKey))

			logrus.Infof("Namespace: %v | IAM Username: %v | Msg: Createing New Secrets", ns(), iamUserName)
			sdk.Create(
				createAwsSecret(
					secretName, ns(),
					metdataLabels,
					accessKey,
					secretKey,
				),
			)
		}

		// create the bucket
		err := CreateBucket(
			bucket, region, ns(),
			metdataLabels, s3Client,
		)
		if err != nil {
			logrus.Errorf("Namespace: %v | Bucket: %v | Msg: Error while creating bucket ", ns(), bucket, err)
		}
		objectStore.Status.Deployed = true
		err = sdk.Update(objectStore)
		if err != nil {
			logrus.Errorf("Namespace: %v | Bucket: %v | Msg: Failed to update bucket status ", ns(), bucket, err)
		}

	}

	if event.Deleted {
		DeleteBucket(bucket, region, ns(), s3Client)
		decodedAccessKey, _ := base64.StdEncoding.DecodeString(objectStore.Status.AccessKey)
		err := DeleteIamUser(iamUserName, ns(), accessPolicy, fmt.Sprintf("%s", decodedAccessKey), iamClient)
		if err != nil {
			logrus.Errorf("ERROR! ", err)
		}
	}

	return nil
}

func createExternalService(name, ns, endpoint string, labels map[string]string) *v1.Service {
	s := &v1.Service{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Service",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      name,
			Namespace: ns,
			Labels:    labels,
		},
		Spec: v1.ServiceSpec{
			Type:         "ExternalName",
			ExternalName: endpoint,
		},
	}
	return s
}

func createAwsSecret(name, namespace string, labels map[string]string, accessID, secret string) *v1.Secret {
	return &v1.Secret{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Secret",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:      name,
			Namespace: namespace,
			Labels:    labels,
		},
		Type: v1.SecretType("Opaque"),
		Data: map[string][]byte{
			"ACCESS_KEY": []byte(accessID),
			"SECRET_KEY": []byte(secret),
		},
	}
}
