name "nginx_tomcat"
run_lists "recipe[nginx_tomcat::default], recipe[nginx_tomcat::nginx]"