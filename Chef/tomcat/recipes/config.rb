#
# Cookbook:: tomcat
# Recipe:: congig
#
# Copyright:: 2017, The Authors, All Rights Reserved.


########################################
#### 		Node Attributes
########################################
java = node['tomcat']['download']['java']
tomcat_home = node['tomcat']['user']['home']
tomcat_user = node['tomcat']['user']['name']
tomcat_user_shell = node['tomcat']['user']['shell']
tomcat_group = node['tomcat']['group']
tomcat_download_destination = node['tomcat']['download']['destination']
tomcat_download_link = node['tomcat']['download']['src']
tomcat_service_path = node['tomcat']['service']['path']
tomcat_min_mem = node['tomcat']['service']['min_mem']
tomcat_max_mem = node['tomcat']['service']['max_mem']
server_conf_file = node['tomcat']['find_replace']['server_conf']
g_data_bag = search(:groups, "id:tomcat").first
u_data_bag = search(:users, "id:tomcat").first

apt_update 'update' do
	action :periodic
	frequency 86_400
end

package java 

group g_data_bag['id'] { action :create }

directory 'create tomcat home' do
	path tomcat_home
end

user u_data_bag["id"] do
	comment u_data_bag["comment"]
	shell u_data_bag["shell"]
	home u_data_bag["home"]
	group u_data_bag["group"]
	manage_home u_data_bag["manage_home"]
end

remote_file 'download tomcat tarball' do
	action :create
	path tomcat_download_destination
	source tomcat_download_link
end

unzip 'Test' do
	src node['tomcat']['download']['destination']
	dest node['tomcat']['home']['path']
	notifies :run, "execute[change tomcat home dir permissions]", :immediately
end

execute 'change tomcat home dir permissions' do
	action :run
	command "chown -R #{tomcat_user}:#{tomcat_group} #{tomcat_home}"
end

node['tomcat']['find_replace']['port'].each do |find, replace|
	ruby_block "find and replace port " do
		block do
			file = Chef::Util::FileEdit.new(server_conf_file)
			file.search_file_replace("Connector port=\"#{find}\"", "Connector port=\"#{replace}\"")
			file.write_file
		end
		not_if {File.readlines(server_conf_file).grep(/<Connector port="#{replace}"/).size > 0}
	end
end

template 'set up tomcat.service file' do
	action :create
	source 'tomcat.service.erb'
	path tomcat_service_path
	variables(
		:min => tomcat_min_mem,
		:max => tomcat_max_mem,
		:user => tomcat_user,
		:group => tomcat_group
	)
	notifies :run, "execute[restart tomcat daemon]", :immediately
end

execute 'restart tomcat daemon' do
	action :nothing
	command 'systemctl daemon-reload'
end


template 'setup tomcat users file' do
	action :create
	source 'tomcat-users.xml.erb'
	path node['tomcat']['tomcat_users']['path']
	notifies :restart, "service[tomcat]", :immediately
end


service 'tomcat' do
	action [:enable, :start]
end
