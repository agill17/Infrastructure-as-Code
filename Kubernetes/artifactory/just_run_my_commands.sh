#!/bin/bash

cd $HOME/infra-as-code/Kubernetes/artifactory
kubectl apply -f artifactory-deployment.yml
kubectl expose deployment artifactory-deployment --type=NodePort

echo "***********************************"
echo "Access artifactory server at: $(minikube service artifactory-deployment --url) "
