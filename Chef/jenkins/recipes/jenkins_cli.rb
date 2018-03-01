
#### PRE_REQ: Auto-ssh must be enabled from jenkins master to node

jenkins_url = node['jenkins']['cli']['jenkins_url']
jenkins_home = node['jenkins']['home']
jenkins_cli = node['jenkins']['cli']['cli_url']
host = node['jenkins']['nodes']['host']
creds = node['jenkins']['nodes']['cred_id']


remote_file 'download jenkins cli jar' do
	path "#{jenkins_home}/jenkins-cli.jar"
	source "#{jenkins_url}/#{jenkins_cli}"
end


cookbook_file 'copy create_node script' do
	path "#{jenkins_home}/create_node.sh"
	source 'create_node.sh'
	mode '0641'
end

execute 'create_node shell script' do
	command "sh #{jenkins_home}/create_node.sh #{jenkins_url} #{host} #{creds}"
end