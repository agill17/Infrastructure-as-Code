jenkins_job 'create a jenkins job' do
	name node['jenkins']['job']['name']
	shell_script node['jenkins']['job']['shell_script']
	github_url node['jenkins']['job']['git_url']
end