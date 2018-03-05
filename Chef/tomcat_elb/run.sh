#!/bin/bash

CHEF="$HOME/chef-repo"
TOMCAT_ELB="$CHEF/cookbooks/tomcat_elb"
VPC_ROLE='tomcat_elb_create_vpc.rb'
TOMCAT_ROLE='tomcat_elb.rb'
TOMCAT_COOKBOOK='tomcat_elb'
cd $CHEF


rm -rf /tmp/tomcat_elb*
set -x
##### provisioner
echo "******************** Stage: Provisioning *************************"
knife role from file $VPC_ROLE
cd $TOMCAT_ELB
### create vpc by local chef-client
chef-client -zr "role[tomcat_elb_create_vpc]"
sleep 2
python provisioner.py
echo 


##### upload cookbook and role
echo "******************** Stage: knife upload *************************"
cd $CHEF
knife role from file $TOMCAT_ROLE
cd $CHEF/cookbooks
knife cookbook upload $TOMCAT_COOKBOOK
echo


##### bootstrap and converge using roles
cd $TOMCAT_ELB
echo 
echo "******************** Role Run List: tomcat_elb ***********************"
knife role show tomcat_elb
echo
echo "******************** Stage: Converge *************************"
python bootstrap.py
echo
