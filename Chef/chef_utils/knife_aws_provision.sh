#!/bin/bash


## PRE-REQ: install knife-ec2, and configure aws credentials for knife to work

CHEF_REPO="$HOME/chef-repo"
AMI_ID=$1
FLAVOR=$2
USER=$3
NAME=$4



all_in_one(){

	knife node show $NAME > /dev/null 2>&1
	
	if [ $? -ne 0 ]
	then 
		echo "$NAME node is not part of chef server"
		echo "Provisioning and bootstrapping it now."

		knife ec2 server create \
			-I ami-$AMI_ID \
			-f $FLAVOR -S aws \
			-i ~/.ssh/aws.pem \
			--ssh-user $USER \
			--node-name $NAME

	else
		echo "$NAME node is already part of chef server. Consider using a different node name...."
		echo "--------CURRENT REGISTERED NODES--------"
		knife node list
	fi

}

cd $CHEF_REPO
all_in_one