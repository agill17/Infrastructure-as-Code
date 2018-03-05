#!/bin/bash

TERRA_DIR="$HOME/infra-as-code/Terraform"

cd $TERRA_DIR
if [ $# -eq 1 ] && [ ! -d $1 ]
then
	mkdir $1
	touch $1/provider.tf 
	touch $1/vars.tf
	touch $1/terraform.tfvars
	touch $1/main_$1.tf
	echo " ----------- Generated Project ===> $1"
	tree $TERRA_DIR/$1	
fi
