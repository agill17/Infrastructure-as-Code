#
# Cookbook:: tomcat
# Recipe:: deploy_war_tomcat
#
# Copyright:: 2017, The Authors, All Rights Reserved.


deploy_artifacts 'deploy war binary' do
	deploy_to "#{node['tomcat']['artifact']['download_path']}/addressbook-2.0.war"
	deploy_from node['tomcat']['artifact']['download_link']
	notifies :restart, "service[tomcat]", :immediately
end

service 'tomcat' do
	action :nothing
end