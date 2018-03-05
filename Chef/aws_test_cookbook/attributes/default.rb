timestamp = Time.now.strftime("%y_%m_%d__%H_%M_%S")

node.default['aws']={
	'VPC' =>
	{
		'name' => 'chef_created_vpc',
		'id' => 'vpc-7c9d911a'
	},

	'NACL' => 
	{
		'name' => 'chef_created_NACL'
	},

	'IGW' =>
	{
		'name' => "chef_created_IGW"
	},

	'S3' =>
	{
		'bucket_name' => "chef_created_bucket"
	},

	'EC2' =>
	{
		'name' => "chef_created_ec2_#{timestamp}",
		'tag' => "chef_created_tag_#{timestamp}"
	},

	'RT' =>
	{
		'name' => 'chef_created_route_table',
		'CIDR' => '0.0.0.0/0'
	},
	'Subnets' =>
	{
		'pub_avail' => '',
		'pri_avail' => '',
		'public' =>
		{
			'subnet_1' =>
			{
				'name' => 'chef_created_subnet_1_public',
				'cidr_block' => '10.0.0.0/28'
			},
			'subnet_2' =>
			{
				'name' => 'chef_created_subnet_2_public',
				'cidr_block' => '10.0.0.16/28'
			}
		},
		'private' =>
		{
			'subnet_1' =>
			{
				'name' => 'chef_created_subnet_1_private',
				'cidr_block' => '10.0.0.32/28'
			},
			'subnet_2' =>
			{
				'name' => 'chef_created_subnet_2_private',
				'cidr_block' => '10.0.0.48/28'
			}
		}

	}
}


# node ={
#  'Subnets' =>
# 	{
# 		'public' =>
# 		{
# 			'subnet_1' =>
# 			{
# 				'name' => 'chef_created_subnet_1_public',
# 				'cidr_block' => '172.31.96.0/20',
# 				'route_table' => 'rtb-6f97b615',
# 			},
# 			'subnet_2' =>
# 			{
# 				'name' => 'chef_created_subnet_2_public',
# 				'cidr_block' => '172.31.112.0/20',
# 				'route_table' => 'rtb-6f97b615',
# 			}
# 		},
# 		'private' =>
# 		{
# 			'subnet_1' =>
# 			{
# 				'name' => 'chef_created_subnet_1_private',
# 				'cidr_block' => '172.31.128.0/20',
# 				'route_table' => 'rtb-c894b5b2',
# 			},
# 			'subnet_2' =>
# 			{
# 				'name' => 'chef_created_subnet_2_private',
# 				'cidr_block' => '172.31.144.0/20',
# 				'route_table' => 'rtb-c894b5b2',
# 			}
# 		},

# 	}
# }

# node['Subnets']['public'].each do |k,v|
# 	p v['name']
# end
