require 'chef/provisioning/aws_driver'
with_driver 'aws'

vp = search(:aws_vpc, "id:#{node['aws']['VPC']['name']}").first

aws_internet_gateway node['aws']['IGW']['name'] do
	action :create
	vpc vp['reference']['id']
end