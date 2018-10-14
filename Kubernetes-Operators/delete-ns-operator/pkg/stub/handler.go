package stub

import (
	"context"
	"fmt"
	"os/exec"
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
	if err != nil {
		return fmt.Errorf("failed to list n: %v", err)
	}
	annotKey := availObjs.Spec.SaveIfAnnotationHas.Key
	annotVal := availObjs.Spec.SaveIfAnnotationHas.Value
	if len(annotKey) == 0 || len(annotVal) == 0 {
		err = fmt.Errorf("spec.SaveIfAnnotationHas.key and spec.SaveIfAnnotationHas.value cannot be empty!!!")
	} else {
		filterAndDelete(nsListObj.Items, availObjs.Spec.OlderThan,
			availObjs.Spec.DryRun, annotKey, annotVal, availObjs.GetNamespace(), availObjs, availObjs.Spec.DefaultHelmSuffix)
	}
	return nil
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

func filterAndDelete(ns []v1.Namespace, olderThan int, dryRun bool, safeKey, safeVal, operatorNs string, crSpec *v1alpha1.DeleteNs, defaultHelmReleaseSuffix string) {
	logrus.Infof("-------------------------------B E G I N  S C A N---------------------------------")
	logrus.Infof("Namespaces older than %vhr(s) will be deleted", olderThan)
	defualtExcludes := map[string]string{"default": "ns", "kube-system": "ns", "kube-public": "ns", operatorNs: "ns"}
	for _, ele := range ns {
		timeDiff := int(time.Now().Sub(ele.CreationTimestamp.Time).Hours())
		nsAnnotVal, nsAnnotKeyExists := ele.Annotations[safeKey]
		_, ok := defualtExcludes[ele.Name]
		if timeDiff >= olderThan && !ok && ele.Status.Phase != "Terminating" {
			releaseNames := []string{ele.Name, ele.Name + defaultHelmReleaseSuffix}
			if (!nsAnnotKeyExists) || (nsAnnotKeyExists && nsAnnotVal != safeVal) {
				if dryRun {
					logrus.Infof("dryRun enabled: %v", dryRun)
					logrus.Infof("No namesapce will be deleted")
					logrus.Infof("Namespace: %v, would get deleted if dryRun was not enabled.", ele.Name)
					logrus.Infof("Release Names: %v would get deleted if dryRun was disabled.", releaseNames)
				} else {
					logrus.Warnf("Namespace: %v | Current Age: %v | Policy Age: %v", ele.Name, timeDiff, olderThan)
					deleteReleasesIfExists(crSpec, releaseNames...)
					deleteNs(ele.Name)
				}
			}
		}
	}
	logrus.Infof("---------------------------------E N D  S C A N-----------------------------------")
	fmt.Printf("-\n")
	fmt.Printf("-\n")
}

func deleteReleasesIfExists(crSpec *v1alpha1.DeleteNs, releaseNames ...string) {
	tillerNamespace := fmt.Sprintf("--tiller-namespace=%v", crSpec.Spec.TillerNamespace)
	for _, x := range releaseNames {
		if exists := releaseExists(x, tillerNamespace); exists {
			logrus.Warnf("ReleaseName: %v | Exists: %v", x, exists)
			out, _ := exec.Command("helm", "del", "--purge", tillerNamespace, x).Output()
			logrus.Infof("Helm delete output: %v", string(out))
		} else {
			logrus.Warnf("ReleaseName: %v | Exists: %v", x, exists)
		}
	}
}

func releaseExists(releaseName, tillerNamespace string) bool {
	exists := false
	args := []string{tillerNamespace, "get", releaseName}
	_, err := exec.Command("helm", args...).Output()
	if err != nil {
		exists = false
	} else {
		exists = true
	}
	return exists

}
