#
# Cookbook:: nagios
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

all_packs = node['nagios']['packs']
n_link = node['nagios']['dl_link']
n_path = node['nagios']['dl_path']
dl_path = node['nagios']['dl_path']
u_data_bag = search(:users, "id:nagios").first
g_data_bag = search(:groups, "id:nagios").first


all_packs.each do |pack|
	package pack
end

group g_data_bag['id']

user u_data_bag['id'] do
	action :create
	manage_home u_data_bag['manage_home']
	home u_data_bag['home']
	group u_data_bag['group']
end


remote_file 'download nagios tarball' do
	action :create
	path n_path
	source n_link
	notifies :run, 'execute[extract nagios]', :immediately
end

execute 'extract nagios' do
	action :nothing
	command "tar -xvf #{n_path} -C /home"
	not_if { Dir.exists?("/home/nagiosxi")}
	notifies :delete, 'file[remove zip file]', :immediately
end
 
file 'remove zip file' do
	path n_path
	action :nothing
end

### -y => not working 
bash 'install' do
	code <<-EOH
	cd /home/nagiosxi
	./fullinstall -y
	EOH
	ignore_failure true
end