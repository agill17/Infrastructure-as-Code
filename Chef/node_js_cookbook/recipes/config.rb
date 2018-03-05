#
# Cookbook:: node_js
# Recipe:: config
#
# Copyright:: 2017, The Authors, All Rights Reserved.

execute 'update yum cache' do
	action :run
	command "yum update -y"
end

bash 'exeute node_js script to install' do
	code <<-EOH
	curl --silent --location #{node['node_js']['dl_link']} | bash -
	EOH
	not_if { File.exists?('/usr/bin/node') }
end

package 'nodejs'

node['node_js']['packs'].each do |pack, check_file_exists|
	execute 'install each node js pack' do
		command "npm install -g #{pack}"
		not_if { File.exists?("#{check_file_exists}")}
	end
end

## needed so that we can install yarn using yum install
yum_repository "yarn" do
	action :create
	baseurl node['node_js']['repo']['yarn_base_url']
	gpgkey node['node_js']['repo']['yarn_gpg_key']
end

%w(yarn unzip).each do |pack|
	package pack
end

directory 'create app directory' do
	path node['node_js']['app']['path_to_extract']
	action :create
end

remote_file 'download yarn repo from git' do
	path node['node_js']['app']['path_to_save']
	source node['node_js']['app']['dl_link']
	notifies :run, "execute[unzip app repo]", :immediately
end

execute 'unzip app repo' do
	action :nothing
	command "unzip -o #{node['node_js']['app']['path_to_save']} -d  #{node['node_js']['app']['path_to_extract']}" 
	only_if { !File.exists?(node['node_js']['app']['check_file_exisitance'])}
end

bash 'download dependencies and start app' do
	action :run
	code <<-EOJ
	cd #{node['node_js']['app']['path_to_extract']}/sample_node_js_app-master
	yarn install 
	pm2 start --name app main.js
	EOJ
	not_if {}
end