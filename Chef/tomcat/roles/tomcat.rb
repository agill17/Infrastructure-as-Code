name "tomcat"
description "Used to configure tomcat and deploy war binaries"
run_list "recipe[devops_check_basic::package_check]",
		 "recipe[tomcat::config]",
		 "recipe[tomcat::deploy_war_tomcat]"
