name "httpd_nginx"
run_list 'recipe[httpd_nginx::default]',
		 'recipe[httpd_nginx::httpd_nginx]'