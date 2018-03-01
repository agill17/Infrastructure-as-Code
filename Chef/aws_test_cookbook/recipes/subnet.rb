require 'chef/provisioning/aws_driver'

with_driver 'aws'

vp = search(:aws_vpc, "id:#{node['aws']['VPC']['name']}").first
private_rt = "#{node['aws']['RT']['name']}_private" ## no igw attached
public_rt = "#{node['aws']['RT']['name']}_public" ## with igw attached
route_table_w_igw = search(:aws_route_table, "id:#{public_rt}").first
route_table_wo_igw = search(:aws_route_table, "id:#{private_rt}").first

## public subnets
node['aws']['Subnets']['public'].each do |k, v|
	aws_subnet v['name'] do
		vpc vp['reference']['id']
		cidr_block v['cidr_block']
		route_table route_table_w_igw['reference']['id']
	end
end

## private subnets
node['aws']['Subnets']['private'].each do |k, v|
	aws_subnet v['name'] do
		vpc vp['reference']['id']
		cidr_block v['cidr_block']
		route_table route_table_wo_igw['reference']['id']
	end
end