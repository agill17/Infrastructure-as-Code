resource_name :jenkins_job
property :name, String, default: 'sample_job'
property :shell_script, String, default: "echo 'Chef is CRAZY!'"
property :github_url, String
property :git_branch, String, default: 'master'
default_action :create

action :create do

	directory "create job directory -- #{name}" do
		action :create
		path "#{node['jenkins']['home']}/jobs/#{name}"
	end

	template "create job config -- #{name}" do
		action :create
		source 'job.xml.erb'
		path "node['jenkins']['home']/jobs/#{name}/#{name}_config.xml"
		variables(
			:j_name => name, 
			:git_url => github_url,
			:branch => git_branch,
			:script => shell_script
		)
	end


end