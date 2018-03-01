#
# Cookbook:: devops_check_basic
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


cron 'run chef-client' do
	user 'root'
	hour '23'
	minute '0'
	command '/usr/bin/chef-client'
end

cron 'run backups on var' do
	user 'root'
	hour '22'
	minute '0'
	command "#{node['file']['path']}/backup.sh /var"
end