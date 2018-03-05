#
# Cookbook:: postgresql
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

execute "update" do
	user 'root'
	command "yum update -y"
end 