#!/bin/bash

sudo yum update -y
sudo yum install ansible -y

if [ -f "/etc/ansible/hosts" ]
then
	sudo ansible localhost -m ping
else
	echo "Could not locat the ansible hosts file..."
	echo "Check if ansible is actually installed!!!!"
fi
