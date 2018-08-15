package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type S3List struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata"`
	Items           []S3 `json:"items"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type S3 struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata"`
	Spec              S3Spec           `json:"spec"`
	MinioSpecs        MinioBucketSpecs `json:",minioSpecs"`
	S3Specs           S3BucketSpecs    `json:",s3Specs"`
	Status            S3Status         `json:"status,omitempty"`
}

type S3BucketSpecs struct {
	BucketName string   `json:",bucketName"`
	SyncWith   SyncWith `json:",syncWith"`
	Region     string   `json:",region"`
}

type MinioBucketSpecs struct {
	// minio for now
	BucketName string              `json:",inline"`
	SyncWith   []map[string]string `json:",syncWith"`
	DataDir    string              `json:",inline"`
	Labels     map[string]string   `json:",inline"`
	SecretKey  string              `json:",inline"`
	AccessKey  string              `json:",inline"`
}

type SyncWith struct {
	BucketName string `json:",bucketName"`
	Region     string `json:",inline"`
}

type S3Status struct {
	Deployed bool
}

type S3Spec struct {
}
