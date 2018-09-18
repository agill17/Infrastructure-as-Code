package stub

import (
	"context"
	"time"

	"github.com/agill17/delete-ns-operator/pkg/apis/amritgill/v1alpha1"
	"github.com/operator-framework/operator-sdk/pkg/sdk"
	"github.com/sirupsen/logrus"
	"k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func NewHandler() sdk.Handler {
	return &Handler{}
}

type Handler struct {
	// Fill me
}

func (h *Handler) Handle(ctx context.Context, event sdk.Event) error {
	availObjs := event.Object.(*v1alpha1.DeleteNs)
	nsListObj := getNsListObj()
	err := sdk.List("", nsListObj)

	crNamespaceName := availObjs.GetNamespace()
	permanent := availObjs.Spec.Permanent
	deleteAfter := availObjs.Spec.AutoDeleteAfter
	nsList := nsListObj.Items

	for _, ele := range nsList {
		if ele.Name == crNamespaceName {
			nsCreationTime := ele.CreationTimestamp.Time
			timeDiff := int(time.Now().Sub(nsCreationTime).Hours())

			logrus.Infof("Namespace: %v | Current Age: %v hour(s) | AutoDeleteAfter: %v hour(s) | Permanent: %v", crNamespaceName, timeDiff, deleteAfter, permanent)

			if !permanent && timeDiff >= deleteAfter {
				deleteNs(crNamespaceName)
			}
		}

	}

	return err
}

func deleteNs(namespace string) {
	ns := &v1.Namespace{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Namespace",
			APIVersion: "v1",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name: namespace,
		},
	}
	logrus.Infof("Deleting Namespace: %v", namespace)
	sdk.Delete(ns)
}

func getNsListObj() *v1.NamespaceList {
	nsPointer := &v1.NamespaceList{
		TypeMeta: metav1.TypeMeta{
			Kind:       "Namespace",
			APIVersion: "v1",
		},
	}

	return nsPointer
}
