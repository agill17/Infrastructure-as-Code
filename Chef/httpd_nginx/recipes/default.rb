#
# Cookbook:: httpd_nginx
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


apt_update 'update apt cache daily' do
	frequency 86_400
	action :periodic
end