#
# Cookbook:: nginx-tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

execute 'update yum packages' do
	command 'yum update -y'
end
