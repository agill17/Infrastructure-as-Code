name 'vpc'
run_list 'recipe[aws_test_cookbook::ec2]',
		 'recipe[aws_test_cookbook::s3]', 
		 'recipe[aws_test_cookbook::IGW]',
		 'recipe[aws_test_cookbook::route_table]'