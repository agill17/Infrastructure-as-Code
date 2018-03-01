#
# Cookbook:: apache_v2
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

## update yum caches
execute 'update yum packages' do
	user 'root'
	command 'yum update -y'
end
