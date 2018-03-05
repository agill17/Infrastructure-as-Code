#
# Cookbook:: jenkins
# Recipe:: war_installation
#
# Copyright:: 2017, The Authors, All Rights Reserved.


remote_file 'download jenkins war' do
	source node['jenkins']['war']['dl']
	path node['jenkins']['war']['path']
	mode '0755'
end	


## not idempotent
execute 'start jenkins' do
	command 'java -Djenkins.install.runSetupWizard=false -jar jenkins.war > jenkins_startup.txt &'
end