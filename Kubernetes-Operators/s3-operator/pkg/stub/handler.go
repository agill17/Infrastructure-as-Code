package stub

import (
	"context"
	"fmt"

	"github.com/sirupsen/logrus"

	"github.com/agill17/s3-operator/pkg/apis/amritgill/v1alpha1"
	"github.com/operator-framework/operator-sdk/pkg/sdk"
)

func NewHandler() sdk.Handler {
	return &Handler{}
}

type Handler struct {
	// Fill me
}

func (h *Handler) Handle(ctx context.Context, event sdk.Event) error {
	s3 := event.Object.(*v1alpha1.S3)
	ns := s3.GetNamespace
	metdataLabels := s3.ObjectMeta.GetLabels()
	if _, exists := metdataLabels["namespace"]; !exists {
		metdataLabels["namespace"] = ns()
	}
	if s3.Status.Deployed != true {
		logrus.Infof("Creating %v bucket in %v for namespace: ", s3.S3Specs.BucketName, s3.S3Specs.Region, ns())
		err := CreateBucket(
			s3.S3Specs.BucketName,
			s3.S3Specs.Region,
			s3.S3Specs.SyncWith.BucketName,
			ns(),
			metdataLabels,
		)
		if err != nil {
			logrus.Errorf("Something failed while creating the s3 bucket for namespace: ", ns)
		} else {
			s3.Status.Deployed = true
			err := sdk.Update(s3)
			if err != nil {
				return fmt.Errorf("failed to update s3 status: %v", err)
			}
		}
	}

	if event.Deleted {
		DeleteBucket(s3.S3Specs.BucketName, s3.S3Specs.Region, ns())
	}

	return nil
}
