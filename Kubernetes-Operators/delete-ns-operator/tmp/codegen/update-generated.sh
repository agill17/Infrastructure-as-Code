#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

vendor/k8s.io/code-generator/generate-groups.sh \
deepcopy \
github.com/agill17/delete-ns-operator/pkg/generated \
github.com/agill17/delete-ns-operator/pkg/apis \
amritgill:v1alpha1 \
--go-header-file "./tmp/codegen/boilerplate.go.txt"
