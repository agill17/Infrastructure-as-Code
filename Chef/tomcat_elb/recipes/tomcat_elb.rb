require 'json'
#
# Cookbook:: tomcat_elb
# Recipe:: tomcat_elb
#
# Copyright:: 2018, The Authors, All Rights Reserved.

### ahhh f it... make it for ubuntu and centos -- because I am a savage boy....

include_recipe 'devops_check_basic::package_check'

#####################################################################
#####################################################################
### 		version for centos - 8
### 		version for ubuntu - 8
#####################################################################
#####################################################################

#####################################################################
#####################################################################
#### 			set up some variables
#####################################################################
#####################################################################
tomcat_home_dir = node['tomcat']['common']['home_dir']
tomcat_dl_link = node['tomcat']['common']['dl_link']
rhel_java_min = node['tomcat']['rhel']['java']['min']
rhel_java_max = node['tomcat']['rhel']['java']['max']
user_bag = search(:tomcat_elb, 'id:tomcat_users').first
group_bag = search(:tomcat_elb, 'id:tomcat_group').first
# tomcat_users = search(:tomcat_rhel_tomcat_gui_users, 'id:tomcat_gui_admin_users')
# rhel_java_home = node['tomcat']['rhel']['java']['home']

#####################################################################
#####################################################################
#### common stuff for both os families
#####################################################################
#####################################################################
user 'create user: tomcat' do
	manage_home user_bag['manage_home']
	username user_bag['user_name']
	shell user_bag['shell']
	home user_bag['home']
end

group 'create group: tomcat' do
	action :create
	group_name group_bag['group_name']
	members group_bag['members']
end

directory 'create tomcat home' do
	path tomcat_home_dir
	action :create
	owner user_bag['user_name']
	group group_bag['group_name']
end

remote_file 'Download tomcat tar file' do
	path "#{Chef::Config[:file_cache_path]}/apache-tomcat-8.5.24.zip"
	source tomcat_dl_link
end

bash 'unzip tomcat.zip' do
	cwd tomcat_home_dir
	code <<-EOS
	 unzip -o #{Chef::Config[:file_cache_path]}/apache-tomcat-8.5.24.zip -d #{tomcat_home_dir}
	 cp -r apache-tomcat-8.5.24/* #{tomcat_home_dir}
	 if [ -d #{tomcat_home_dir}/apache-tomcat-8.5.24 ]
	 then
	 	rm -rf #{tomcat_home_dir}/apache-tomcat-8.5.24
	 fi
	 EOS
	not_if { Dir.exist?("#{tomcat_home_dir}/webapps") and !Dir.exist?("#{tomcat_home_dir}/apache-tomcat-8.5.24") }
end

execute 'Change owner and group recursively' do
	command "chown -R #{user_bag['user_name']}:#{group_bag['group_name']} #{tomcat_home_dir}"
end

#####################################################################
#####################################################################
#### os specific
#####################################################################
#####################################################################

case node['platform_family']

when 'rhel'

	execute 'update yum' do
		command 'yum update -y'
	end

	template 'set up tomcat.service file' do
		source 'tomcat_rhel.service.erb'
		path  node['tomcat']['rhel']['service_file']
		variables(
			java_min: rhel_java_min,
			java_max: rhel_java_max,
			user: user_bag['user_name'],
			group: group_bag['group_name'],
			tomcat_home: tomcat_home_dir
		)
		notifies :run, 'execute[daemon-reload]', :immediately
	end

	execute 'daemon-reload' do
		command 'systemctl daemon-reload'
	end

	search(:tomcat_rhel_tomcat_gui_users, 'comment:tomcat amdin users for GUI').each do |db|
		template 'tomcat admin users for GUI' do
			path "#{tomcat_home_dir}/conf/tomcat-users.xml"
			source 'tomcat_rhel_tomcat-users.xml.erb'
			variables(
				username: db['user_name'],
				password: db['password'],
				role: db['role']
			)
		end
	end

		## change default port of 8080 to something else for now

when 'debian'

	apt_update 'update apt repo' do
		action :periodic
		frequency 86_400 ## every 24 hrs
	end
end

service 'tomcat' do
	user 'tomcat'
	action [:enable, :start]
end
