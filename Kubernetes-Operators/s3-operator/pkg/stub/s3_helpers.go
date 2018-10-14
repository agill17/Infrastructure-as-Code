package stub

import (
	"fmt"

	"github.com/sirupsen/logrus"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
)

type s3Input struct {
	s3Svc                         *s3.S3
	bucketName, region, namespace string
	bucketTags                    map[string]string
}

func (s *s3Input) bucketExists() bool {
	exists := true
	_, err := s.s3Svc.GetBucketLocation(&s3.GetBucketLocationInput{Bucket: &s.bucketName})
	if awserr, ok := err.(awserr.Error); ok && awserr.Code() == s3.ErrCodeNoSuchBucket {
		exists = false
	}
	return exists
}

// Assumes empty the bucket and then delete it
// Perhaps this can be parameterized
func (s *s3Input) deleteBucket() {

	if s.bucketExists() {
		iter := s3manager.NewDeleteListIterator(s.s3Svc, &s3.ListObjectsInput{
			Bucket: aws.String(s.bucketName),
		})
		logrus.Infof("namespace: %v | Bucket: %v | Msg: Deleting all objects ", s.namespace, s.bucketName)

		err := s3manager.NewBatchDeleteWithClient(s.s3Svc).Delete(aws.BackgroundContext(), iter)
		errorCheck(err, func() {
			logrus.Errorf("namespace: %v | Bucket: %v | Msg: Unable to delete objects %v", s.namespace, s.bucketName, err)
		})
		logrus.Infof("namespace: %v | Bucket: %v | Msg: Deleted all objects ", s.namespace, s.bucketName)

		_, err = s.s3Svc.DeleteBucket(&s3.DeleteBucketInput{Bucket: aws.String(s.bucketName)})
		errorCheck(err, func() {
			logrus.Errorf("namespace: %v | Bucket: %v | Msg: Unable to delete bucket %v", s.namespace, s.bucketName, err)
		})

		err = s.s3Svc.WaitUntilBucketNotExists(&s3.HeadBucketInput{
			Bucket: aws.String(s.bucketName),
		})
		errorCheck(err, func() {
			logrus.Errorf("namespace: %v | Bucket: %v | Msg: Error while deleting bucket %v", s.namespace, s.bucketName, err)
		})
		logrus.Infof("namespace: %v | Bucket: %v | Msg: Bucket Deleted ", s.namespace, s.bucketName)

	} else {
		logrus.Errorf("namespace: %v | Bucket: %v | Msg: Bucket does not exist while deleting %v", s.namespace, s.bucketName)
	}
}

func (s *s3Input) createBucketIfDoesNotExist() {

	bucket := s.bucketName
	t := []*s3.Tag{}
	for k, v := range s.bucketTags {
		t = append(t, &s3.Tag{Key: aws.String(k), Value: aws.String(v)})
	}
	var err error
	// Create the S3 Bucket
	if !s.bucketExists() {
		_, err = s.s3Svc.CreateBucket(&s3.CreateBucketInput{Bucket: aws.String(bucket)})
		errorCheck(err, func() {
			logrus.Errorf("namespace: %v | Bucket: %v | Msg: Unable to create bucket %v", s.namespace, s.bucketName, err)
		})

		err = s.s3Svc.WaitUntilBucketExists(&s3.HeadBucketInput{Bucket: aws.String(bucket)})
		errorCheck(err, func() {
			logrus.Errorf("namespace: %v | Bucket: %v | Msg: Error occured while bucket creation %v", s.namespace, s.bucketName, err)
		})
		addTagsToS3Bucket(bucket, t, s.s3Svc)
		logrus.Infof("namespace: %v | Bucket: %v | Msg: Bucket created successfully", s.namespace, s.bucketName)

	} else {
		logrus.Warnf("namespace: %v | Bucket: %v | Msg: Bucket already exists", s.namespace, s.bucketName)
	}
}

func SyncBucketWith(newBucket, oldBucket, region string, svc *s3.S3) {
	// sync
	// cross account? or same account ? or both ( ideal? )
}

func addTagsToS3Bucket(whichBucket string, tags []*s3.Tag, svc *s3.S3) {
	tagInput := &s3.PutBucketTaggingInput{
		Bucket: &whichBucket,
		Tagging: &s3.Tagging{
			TagSet: tags,
		},
	}

	_, err := svc.PutBucketTagging(tagInput)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			fmt.Println(err.Error())
		}
	}
}
