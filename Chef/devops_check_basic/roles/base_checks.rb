name "Base_checks"
description "Used to verify system is update to date and meets desired criteria"
run_list 'recipe[devops_check_basic::default]',
		 'recipe[devops_check_basic::files]',
		 'recipe[devops_check_basic::package_check]',
		 'recipe[devops_check_basic::system_check]'