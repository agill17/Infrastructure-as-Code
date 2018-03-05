require 'chef/provisioning/aws_driver'
with_driver 'aws'

aws_vpc node['aws']['VPC']['name'] do
  cidr_block "10.0.0.0/24"
  internet_gateway false
end
