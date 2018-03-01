require 'chef/provisioning/aws_driver'
with_driver 'aws'

igw_data_bag = search(:aws_internet_gateway, "id:#{node['aws']['IGW']['name']}").first
vp = search(:aws_vpc, "id:#{node['aws']['VPC']['name']}").first


# From Docs
#The destination (the left side of the `=>`) is always a CIDR block.
# The target (the right side of the `=>`) can be one of several things:

### Connect to an IGW for public subnets

aws_route_table "#{node['aws']['RT']['name']}_public" do
	action :create
	vpc vp['reference']['id']
	routes node['aws']['RT']['CIDR'] => igw_data_bag['reference']['id']
	
end

### No connection to IGW for private subnets
aws_route_table "#{node['aws']['RT']['name']}_private" do
	action :create
	vpc vp['reference']['id']
end