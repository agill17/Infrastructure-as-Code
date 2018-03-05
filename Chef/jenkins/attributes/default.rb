key = nil
base_url = nil
java = nil
conf = nil

case node['platform_family']

when 'rhel'
	key = "http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
	base_url = "http://pkg.jenkins-ci.org/redhat"
	java = 'java-1.8.0-openjdk-devel'
	conf = '/etc/sysconfig/jenkins'
when 'debian'
	key = "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key"
	base_url = "http://pkg.jenkins-ci.org/debian/"
	java = 'default-jdk'
	conf = '/etc/default/jenkins'
else
	Chef::Log.fatal("#{node['platform_family']} is not yet configured to work with this cookbook...")
end




node.default['jenkins']=
{
	'war' =>
	{
		'dl' => "http://mirrors.jenkins.io/war-stable/latest/jenkins.war",
		'path' => '/tmp/jenkins.war'
	},
	'which_key' => "#{key}",
	'which_url' => "#{base_url}",
	'user' => 'jenkins',
	'group' => 'jenkins',
	'shell' => '/bin/bash',
	'home' => '/var/jenkins',
	'which_java' => "#{java}",
	'JENKINS_CONFIG' =>
	{
		'path' => "#{conf}",
		'JENKINS_HOME' => '/var/jenkins',
		'JENKINS_PORT' => '8080',
	},
	'job'=>
	{
		'name' => 'sample_test',
		'git_url' => 'https://github.com/agill17/tomcat_cookbook.git',
		'shell_script' => "export PATH=/sbin:/usr/sbin:/usr/bin:/usr/local/bin
kitchen verify"
	},
	'cli' =>
	{
		'jenkins_url' => "http://localhost:8080",
		'cli_url' => "jnlpJars/jenkins-cli.jar"
	},
	'nodes' => 
	{
		'host' => 'ip',
		'cred_id' => 'creds'
	}
}

