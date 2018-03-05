#
# Cookbook:: tomcat_elb
# Recipe:: elb
#
# Copyright:: 2018, The Authors, All Rights Reserved.
require 'json'
require 'chef/provisioning/aws_driver'
names = []
bootstraps = JSON.parse(File.read('/tmp/tomcat_elb_bootstrap_infos.json'))

bootstraps.each do |x|
	names.push(x['name'])
end


# ## classic type
load_balancer 'tomcat_elb' do
	machines names
	driver 'aws'
	load_balancer_options :listeners => [{
        :port => 80,
        :protocol => :http,
        :instance_port => 80,
        :instance_protocol => :http,
    }]
end