require 'chef/provisioning/aws_driver'

with_driver 'aws'


## ignore_failure true because,
## Figure out how to use some of the properties..
## It has not been documented yet.... eh
## Add rule_number, rule_action, inbound/outbound rules
## Attach a subnet
# aws_network_acl node['aws']['NACL']['name'] do
# 	vpc node['aws']['VPC']['id']
# 	:rule_number 100
# 	:rule_action 'ALLOW'
# 	inbound_rules [
#   	{ port: 22, protocol: :tcp, sources: '0.0.0.0/0' }
# 	]
# 	ignore_failure true
# end