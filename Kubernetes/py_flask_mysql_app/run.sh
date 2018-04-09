#!/bin/bash

cd deployment

kubectl apply -f db_deployment.yml
kubectl apply -f db_svc.yml

kubectl apply -f app_deployment.yml
kubectl apply -f app_svc.yml
