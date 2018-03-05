#
# Cookbook:: apache_v2
# Recipe:: config
#
# Copyright:: 2017, The Authors, All Rights Reserved.

httpd_user = node['httpd']['user']['name']
httpd_user_home = node['httpd']['user']['home']
httpd_shell = node['httpd']['user']['shell']
all_sites = node['httpd']['sites']
all_vhosts = node['httpd']['vhost']
site_available = node['httpd']['vhost']['available_path']
site_enabled = node['httpd']['vhost']['enabled_path']

package 'httpd' do
	action :install
end

service 'httpd' do
	action [:enable, :start]
end

user  httpd_user do
	action :create
	manage_home true
	home httpd_user_home
	shell httpd_shell
	notifies :restart, "service[httpd]", :delayed
end

all_vhosts.each do |k, v|
	directory v
end

#TODO: replace this with a custom resource?
all_sites.each do | site_name , site_values|
	site_values.each do |path_var,path|
		
		directory path do
			action :create
			owner httpd_user
			group httpd_user
			mode '0755'
		end

		template 'create each html file' do
			action :create
			path "#{path}/#{site_name}.html"
			source "sites.html.erb"
			owner httpd_user
			group httpd_user
			variables(
				:site_num => site_name
			)
		end

		template 'create vhost entry for each' do
			action :create
			path "#{node['httpd']['vhost']['available_path']}/#{site_name}.com.conf"
			source 'vhosts.erb'
			variables(
				:server_name => site_name
			)
		end

		execute 'enable sites in site-enabled' do
			command "sudo ln -s #{site_available}/#{site_name}.com.conf #{site_enabled}/#{site_name}.com.conf"
			not_if {File.exists?("#{site_enabled}/#{site_name}.com.conf")}
		end

	end
end


#need a better solution for this - its not idempotent
execute 'change mode of www folder' do
	command "chmod -R 755 /var/www"
end


#
service 'httpd' do
	action :nothing
end

