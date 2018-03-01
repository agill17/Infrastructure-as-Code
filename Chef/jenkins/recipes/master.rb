#
# Cookbook:: jenkins
# Recipe:: master
#
# Copyright:: 2017, The Authors, All Rights Reserved.


base_url = node['jenkins']['which_url']
which_key = node['jenkins']['which_key']
jenkins_group = node['jenkins']['group']
jenkins_user = node['jenkins']['user']
jenkins_shell = node['jenkins']['shell']
jenkins_user_home = node['jenkins']['home']
jenkins_conf = node['jenkins']['JENKINS_CONFIG']['path']
jenkins_home = node['jenkins']['JENKINS_CONFIG']['JENKINS_HOME']
jenkins_port = node['jenkins']['JENKINS_CONFIG']['JENKINS_PORT']


group jenkins_group

user jenkins_user do
	shell jenkins_shell
	group jenkins_group
	manage_home true
	home jenkins_user_home
end

case node['platform_family']

when 'rhel'
	yum_repository 'jenkins' do
		baseurl base_url
		gpgkey which_key
	end

	package 'jenkins'

	template 'change config.xml file' do
	path jenkins_conf
	source 'jenkins_rhel_master_config.xml.erb'
	variables(
		:j_home => jenkins_home,
		:j_user => jenkins_user,
		:j_port => jenkins_port
 	)
end


when 'debian'
	apt_repository 'jenkins' do
		distribution 'binary/'
		uri base_url
		key which_key
	end

	package 'jenkins'

	template 'change config.xml file' do
		path jenkins_conf
		source 'jenkins_deb_master_config.xml.erb'
		variables(
			:j_home => jenkins_home,
			:j_user => jenkins_user,
			:j_port => jenkins_port,
			:j_group => jenkins_group
  		)
 	end

else
	Chef::Log.warn("#{node['platform_family']} is not yet configured..")
end



