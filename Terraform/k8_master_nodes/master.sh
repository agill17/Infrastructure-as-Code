#!/bin/bash

### could make this a bit better, but eh its fine...

set -x

GIT_REPO="https://github.com/agill17/Infrastructure-as-Code.git"

### install ansible
sudo yum update -y
sudo yum install ansible -y
sudo yum install git -y

cat <<EOT > /etc/hosts
$(hostname -I) centos-master
EOT

mkdir -p /opt/ansible/local_play
cd /opt/ansible/local_play

git clone $GIT_REPO .
cd /opt/ansible/local_play/Ansible/K8s_master_node_setup

ansible-playbook main.yml -i inventory --tags "base,master"
