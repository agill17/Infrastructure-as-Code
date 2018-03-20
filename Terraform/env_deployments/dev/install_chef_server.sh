#!/bin/bash
set -x

yum install wget git -y

cd /tmp

if [ ! -f chef-server* ]
then
	wget https://packages.chef.io/stable/el/7/chef-server-core-12.10.0-1.el7.x86_64.rpm
fi

rpm -ivh chef-server-core-*.rpm
chef-server-ctl reconfigure
chef-server-ctl status
chef-server-ctl user-create amrit_gill \
	amrit gill amgill1234@gmail.com 'password123!' \
	--filename /home/centos/amrit.pem
chef-server-ctl org-create short_name 'amrit_gill_chef_server_org' \
	--association_user amrit_gill \
	--filename /home/centos/amrit_gill_chef_server_org-validator.pem
# chef-server-ctl install chef-manage
# chef-server-ctl reconfigure
# chef-manage-ctl reconfigure