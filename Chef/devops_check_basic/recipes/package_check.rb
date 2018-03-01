#
# Cookbook:: devops_check_basic
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

case node['platform_family']
when 'debian'
	apt_update 'update' do
		frequency 86_400
		action :periodic
	end
when 'rhel'
	execute 'update' do
		command 'yum update -y'
	end
end

node['required']['packages'].each do |pack|
	package pack
end
