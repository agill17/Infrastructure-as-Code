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
	OlderThan int      `json:",inline"`
	Excludes  []string `json:",inline"`
}

type DeleteNsStatus struct {
	// Fill me
}
