package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type DeleteNsList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata"`
	Items           []DeleteNs `json:"items"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type DeleteNs struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata"`
	Spec              DeleteNsSpec   `json:"spec"`
	Status            DeleteNsStatus `json:"status,omitempty"`
}

type DeleteNsSpec struct {
	OlderThan           int                 `json:"olderThan"`
	DryRun              bool                `json:"dryRun"`
	DefaultHelmSuffix   string              `json:"defaultHelmSuffix"`
	TillerNamespace     string              `json:"tillerNamespace"`
	SaveIfAnnotationHas SaveIfAnnotationHas `json:"saveIfAnnotationHas"`
}
type SaveIfAnnotationHas struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}

type DeleteNsStatus struct {
	// Fill me
}
