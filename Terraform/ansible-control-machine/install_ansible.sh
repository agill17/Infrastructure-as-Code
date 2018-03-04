#!/bin/bash

sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update -y
sudo apt-get install ansible -y

if [ -f "/etc/ansible/hosts" ]
then
	sudo ansible localhost -m ping
else
	echo "Could not locat the ansible hosts file..."
	echo "Check if ansible is actually installed!!!!"
fi