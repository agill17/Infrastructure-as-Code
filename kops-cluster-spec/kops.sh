#!/usr/bin/env bash


CLS=${CLUSTER:-amritgill.tk}
S3=${BUCKET:-kops-state-agill}

set -x

kops create cluster \
--name=${CLS} \
--node-count=${NODE_COUNT:-4} \
--master-count=${MASTER_COUNT:-1} \
--state=s3://${S3} \
--zones=us-east-1a \
--master-zones=us-east-1a \
--encrypt-etcd-storage \
--node-size=${NODE_SIZE:-t2.large} \
--master-size=${MASTER_SIZE:-t2.large} \
--network-cidr=10.0.0.0/16 \
--networking=weave \
--topology=${TOPOLOGY:-private} \
--yes \
--dry-run \
--output yaml > ${CLS}.spec.yaml


kops create --state=s3://${S3} -f ${CLS}.spec.yaml

kops create secret --state=s3://${S3} --name ${CLS} sshpublickey admin -i ~/.ssh/id_rsa.pub

kops update cluster ${CLS} --yes --state=s3://${S3}
