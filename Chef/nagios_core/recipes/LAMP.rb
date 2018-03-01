#
# Cookbook:: nagios_core
# Recipe:: LAMP
#
# Copyright:: 2017, The Authors, All Rights Reserved.


## Just a quick LAMP setup, nothing to fancy

node['nagios']['LAMP']['packs'].each do |p| 
	package p do
		action :install
	end
end

## start httpd
service node['nagios']['LAMP']['packs'][0] do
	action [ :enable, :start]
end


## start mariadb
service node['nagios']['LAMP']['packs'][2] do
	action [ :enable, :start ]
end


