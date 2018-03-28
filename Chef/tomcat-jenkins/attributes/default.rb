
## tomcat

node.default["tomcat"] = {
	"dir" => {
		"home" => "/usr/share/tomcat",
		"webapps" => "/usr/share/tomcat/webapps"
	},
	"conf" => {
		"path" => "/etc/tomcat/tomcat.conf",
		"skip_initial_setup" => "JAVA_OPTS=\"-Djenkins.install.runSetupWizard=false\""
	}
}


## jenkins

node.default["jenkins"] = {
	"war" => {
		"download" => "http://mirrors.jenkins-ci.org/war/latest/jenkins.war"
	}
}


## gradle 
v = "2.8"
node.default["gradle"] = {
	"version" => v,
	"download" => {
		"link" => "https://services.gradle.org/distributions/gradle-#{v}-bin.zip",
		"path" => "/tmp/gradle-#{v}-bin.zip"
	},
	"home" => "/opt/gradle/#{v}/"
}