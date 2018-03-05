require 'chef/provisioning/aws_driver'
with_driver 'aws'

# with_chef_server "https://manage.chef.io/",
#   :client_name => Chef::Config[:node_name],
#   :signing_key_filename => Chef::Config[:client_key]


################### node attributes #######################
vpc_name = node['aws']['VPC']['name']
igw_name = node['aws']['IGW']['name']
rt_name = node['aws']['RT']['name']
rt_cidr = node['aws']['RT']['CIDR']
nacl_name = node['aws']['NACL']['name']
private_rt = "#{node['aws']['RT']['name']}_private" ## no igw attached
public_rt = "#{node['aws']['RT']['name']}_public" ## with igw attached
pub_sub_avail = ENV['AWS_AVAIL_ZONE'] if node['aws']['Subnets']['pub_avail'].size == 0
pri_sub_avail = ENV['AWS_AVAIL_ZONE'] if node['aws']['Subnets']['pri_avail'].size == 0
############################################################

## new vpc
aws_vpc vpc_name do
  cidr_block "10.0.0.0/24"
  internet_gateway false
end

## new igw and attach to new vpc
aws_internet_gateway igw_name do
	action :create
    vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
end

## for public subents and attach to new igw, vpc
aws_route_table "#{rt_name}_public" do
	action :create
	vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
	routes lazy { { rt_cidr => search(:aws_internet_gateway, "id:#{igw_name}").first['reference']['id'] } }
end

## for private subnets and only attach to new vpc
aws_route_table "#{rt_name}_private" do
	action :create
	vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
end

### create nacl layer with rules set for all subnets
aws_network_acl nacl_name do
	vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id']}
  	inbound_rules [{ rule_number: 100, rule_action: :allow, protocol: '-1', cidr_block: '0.0.0.0/0' }]
    outbound_rules [{ rule_number: 100, rule_action: :allow, protocol: '-1', cidr_block: '0.0.0.0/0' }]

end

## public subnets and attach to rt with igw
node['aws']['Subnets']['public'].each do |k, v|
	aws_subnet v['name'] do
		availability_zone pub_sub_avail
		vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
		cidr_block v['cidr_block']
		route_table lazy { search(:aws_route_table, "id:#{public_rt}").first['reference']['id'] }
		network_acl lazy { search(:aws_network_acl, "id:#{nacl_name}").first['reference']['id'] }
	end
end

## private subnets and attach to rt without igw
node['aws']['Subnets']['private'].each do |k, v|
	aws_subnet v['name'] do
		availability_zone pri_sub_avail
		vpc lazy { search(:aws_vpc, "id:#{vpc_name}").first['reference']['id'] }
		cidr_block v['cidr_block']
		route_table lazy { search(:aws_route_table, "id:#{private_rt}").first['reference']['id'] }
		network_acl lazy{search(:aws_network_acl, "id:#{nacl_name}").first['reference']['id']}
	end
end

## machine_batch does creating and converging of all machine resources in parallel!

with_machine_options({
    ssh_username: 'ubuntu',
    bootstrap_options: {
    	key_name: 'YOUR_KEY',
        key_path: 'PATH/TO/KEY',
        image_id: 'ami-da05a4a0',
        instance_type: 't2.micro'
    }
})

machine 'chef_created_ec2_17_11_26__10_02_26' do

end

