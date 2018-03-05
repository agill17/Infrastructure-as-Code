#
# Cookbook:: tomcat_elb
# Recipe:: vpc
#
# Copyright:: 2018, The Authors, All Rights Reserved.
require 'chef/provisioning/aws_driver'
with_driver 'aws'

vpc_name = node['vpc']['name']
igw_name = node['vpc']['igw']['name']
pub_rt_name = node['vpc']['pub_rt']['name']
pri_rt_name = node['vpc']['pri_rt']['name']
pub_sub_name = node['vpc']['pub_subnet']['name']

aws_vpc vpc_name do
	action :create
	cidr_block '10.0.0.0/24'
end

aws_internet_gateway igw_name do
	action :create
	vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
end

aws_route_table pub_rt_name do
	action :create
	vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
	routes lazy { { node['vpc']['pub_rt']['routes']['destination'] => search(:aws_internet_gateway, "id:#{igw_name}").first['reference']['id'] } }
end

aws_route_table pri_rt_name do
	vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
	retries 3
	retry_delay 2
end

## all public subnets mate
{ 'us-east-1a' => '0', 'us-east-1b' => '16', 'us-east-1c' => '32', 'us-east-1d' => '48' }.each do |az, cidr|
	aws_subnet "#{pub_sub_name}-#{az}" do
		action :create
		availability_zone az
		cidr_block "10.0.0.#{cidr}/28"
		vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
		route_table lazy { search(:aws_route_table, "id:#{pub_rt_name}").first['reference']['id'] }
	end
end
