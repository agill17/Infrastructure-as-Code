package stub

import (
	"github.com/sirupsen/logrus"

	"github.com/agill17/s3-operator/pkg/apis/amritgill/v1alpha1"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/iam"
	"github.com/operator-framework/operator-sdk/pkg/sdk"
)

type iamUserInput struct {
	iamClient                            *iam.IAM
	username, accessPolicyArn, namespace string
	accessKeysOutput                     *iam.CreateAccessKeyOutput
	objectStore                          *v1alpha1.S3
}

func (i *iamUserInput) iamUserExists() bool {
	exists := true

	_, err := i.iamClient.GetUser(&iam.GetUserInput{
		UserName: aws.String(i.username),
	})
	if awserr, ok := err.(awserr.Error); ok && awserr.Code() == iam.ErrCodeNoSuchEntityException {
		exists = false
	}
	logrus.Warnf("Namespace: %v | IAM User: %v | Msg: User exists: %v", i.namespace, i.username, exists)

	return exists
}

func (i *iamUserInput) createUserIfDoesNotExists() {
	var err error

	if !i.iamUserExists() {
		_, err = i.iamClient.CreateUser(&iam.CreateUserInput{
			UserName: aws.String(i.username),
		})
		if i.accessPolicyArn != "" {
			_, err := i.iamClient.AttachUserPolicy(&iam.AttachUserPolicyInput{PolicyArn: aws.String(i.accessPolicyArn), UserName: aws.String(i.username)})
			errorCheck(err, func() {
				logrus.Errorf("Namespace: %v | IAM Username: %v | Msg: ERROR while attaching accessPolicy; %v", i.namespace, i.username, err)
			})

		} else {
			logrus.Infof("Namespace: %v | PolicyArn: %v | Msg: Access policy does not exist. Skipping attachment", i.namespace, i.accessPolicyArn)
		}
		i.accessKeysOutput, err = i.iamClient.CreateAccessKey(&iam.CreateAccessKeyInput{
			UserName: aws.String(i.username),
		})
		i.objectStore.Status.AccessKey = encodeDecode(*i.accessKeysOutput.AccessKey.AccessKeyId, "encode")
		i.objectStore.Status.SecretKey = encodeDecode(*i.accessKeysOutput.AccessKey.SecretAccessKey, "encode")
		err = sdk.Update(i.objectStore)
		errorCheck(err, func() {
			logrus.Errorf("ERROR While updating objectStore for Namespace: %v", i.namespace)
		})
	}
}

func (i *iamUserInput) deleteIamUser(accessKeyFromCr string) {
	if i.iamUserExists() {
		logrus.Infof("Namespace: %v | IAM Username: %v | Msg: Deleting user", i.namespace, i.username)

		_, err := i.iamClient.DetachUserPolicy(&iam.DetachUserPolicyInput{PolicyArn: aws.String(i.accessPolicyArn), UserName: aws.String(i.username)})
		errorCheck(err, func() {
			logrus.Errorf("Namespace: %v | IAM Username: %v | Msg: ERROR while detaching accessPolicy; %v", i.namespace, i.username, err)
		})

		_, err = i.iamClient.DeleteAccessKey(&iam.DeleteAccessKeyInput{AccessKeyId: aws.String(accessKeyFromCr), UserName: aws.String(i.username)})
		errorCheck(err, func() {
			logrus.Errorf("Namespace: %v | IAM Username: %v | Msg: ERROR while deleting accessKey; %v", i.namespace, i.username, err)
		})

		_, err = i.iamClient.DeleteUser(&iam.DeleteUserInput{UserName: aws.String(i.username)})
		errorCheck(err, func() {
			logrus.Errorf("Namespace: %v | IAM Username: %v | Msg: ERROR while deleting IAM, %v", i.namespace, i.username, err)
		})

		logrus.Infof("Namespace: %v | IAM Username: %v | Msg: Deleted user", i.namespace, i.username)
	}

}
