#!/usr/bin/env bash


CLS=${CLUSTER:-amritgill.tk}
S3=${BUCKET:-kops-state-sgill}

kops create cluster \
--name=${CLS} \
--node-count=${NODE_COUNT:-5} \
--master-count=${MASTER_COUNT:-3} \
--state=s3://${S3} \
--zones=us-east-1a,us-east-1b,us-east-1c \
--master-zones=us-east-1a,us-east-1b,us-east-1c \
--encrypt-etcd-storage \
--node-size=${NODE_SIZE:-t2.micro} \
--master-size=${MASTER_SIZE:-t2.medium} \
--network-cidr=10.0.0.0/16 \
--networking=weave \
--topology=${TOPOLOGY:-private} \
--yes \
--dry-run \
--output yaml > ${CLS}.spec.yaml


kops create -f ${CLS}.spec.yaml

kops create secret --name ${CLS} sshpublickey admin -i ~/.ssh/id_rsa.pub

kops update cluster ${CLS} --yes --state=s3://${S3}
