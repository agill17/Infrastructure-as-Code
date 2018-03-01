#
# Cookbook:: nginx-tomcat
# Recipe:: nginx
#
# Copyright:: 2017, The Authors, All Rights Reserved.

node['nginx']['packs'].each do |k, v|
	package v do
		action :install
	end
end


service node['nginx']['packs']['pack2'] do
	action [:enable, :start]
end


directory node['nginx']['ssl']['dir'] do
	action :create
	mode '0700'
	recursive true
end

execute "create ssl cert" do
	command 'openssl req -x509 -nodes -x509 -subj "/C=US/ST=VIRGINIA/L=Springfield/O=Dis/CN=www.example.com" -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt'
	not_if { File.exists?("#{node['nginx']['ssl']['certs']}/nginx-selfsigned.crt")}
end