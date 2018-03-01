#
# Cookbook:: jenkins
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
java = node['jenkins']['which_java']

if node['platform_family'] == 'debian'
	apt_update 'update' do
		frequency 86_400
		action :periodic
	end
else
	execute 'update yum_repository' do
		command 'yum update -y'
	end
end

include_recipe "devops_check_basic::package_check"

node['jenkins_plugins'].each do |plug, ver|
   jenkins_plugin plug do
     version ver
   end
end

