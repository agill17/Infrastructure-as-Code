#
# Cookbook:: jenkins
# Recipe:: tomcat
#
# Copyright:: 2017, The Authors, All Rights Reserved.

remote_file 'download jenkins war' do
	source node['tomcat']['jenkins']['war_dl']
	path node['tomcat']['jenkins']['war_path']
	mode '0755'
end	


bash 'move jenkins.war to webapps' do
	code <<-EOH
	mv #{node['tomcat']['jenkins']['war_path']} /opt/tomcat/webapps
	sh /opt/tomcat/bin/startup.sh
	EOH
end
