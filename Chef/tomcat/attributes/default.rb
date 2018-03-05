which_java = nil
case node['platform_family']
when 'rhel' then which_java = 'java-1.8.0-openjdk-devel'
when 'debian' then which_java = 'default-jdk'
end


node.default['tomcat'] =
{
	"group" => "tomcat",
	"user" =>
	{
		"name" => "tomcat",
		'shell' => '/bin/false',
		'home' => '/opt/tomcat'
	},
	"download" =>
	{
		'java' => which_java,
		'src' => 'http://apache.mirrors.hoobly.com/tomcat/tomcat-8/v8.0.47/bin/apache-tomcat-8.0.47.tar.gz',
		'destination' => '/home/apache-tomcat-8.0.47.tar.gz',
		'file_name' => 'apache-tomcat-8.0.47.tar.gz'
	},
	"home" =>
	{
		'path' => '/opt/tomcat/',
		'webapps' => '/opt/tomcat/webapps'
	},
	"service" =>
	{
		'path' => '/etc/systemd/system/tomcat.service',
		'min_mem' => '512M',
		'max_mem' => '1024M'
	},
	"find_replace" =>
	{
		'server_conf' => '/opt/tomcat/conf/server.xml',
		'port' =>
		{
			'8080' => '7070'
		}
	},
	'artifact' =>
	{
		'download_link' => "http://ec2-52-41-108-9.us-west-2.compute.amazonaws.com:8081/artifactory/addressbook/lastStable/archive/target/addressbook-2.0.war",
		'download_path' => '/opt/tomcat/webapps',
		'back_up_dir' => '/opt/tomcat/back_up_arti',
		'arti_file_name' => 'addressbook-2.0.war'
	},
	'jenkins' =>
	{
		'war_dl' => 'http://mirrors.jenkins.io/war-stable/latest/jenkins.war',
		'war_path' => '/tmp/jenkins.war',
	},
	'tomcat_users' =>
	{
		'path' => '/opt/tomcat/conf/tomcat-users.xml'
	}

}