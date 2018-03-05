name 'artifactory'
run_list 'recipe[devops_check_basic::package_check]', 
		 'recipe[artifactory::default]'