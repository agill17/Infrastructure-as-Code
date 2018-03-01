require 'chef/provisioning'
with_driver 'aws'

machine node['aws']['EC2']['name'] do
  action [:setup, :converge_only]
  tag node['aws']['EC2']['tag']
  ignore_failure true
end