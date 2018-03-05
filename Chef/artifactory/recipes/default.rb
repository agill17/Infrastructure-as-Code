#
# Cookbook:: artifactory
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

include_recipe 'devops_check_basic::package_check'

remote_file 'download zip file' do
  action :create
  path node['artifactory']['dl_path']
  source node['artifactory']['dl_link']
end

execute 'extract zip file' do
  action :run
  dl = node['artifactory']['dl_path']
  ext = node['artifactory']['ext_path']
  command "unzip -o #{dl} -d #{ext}"
  not_if { Dir.exist?(node['artifactory']['ext_path']) }
end

bash 'install as service' do
  code <<-EOHG
  cd #{node['artifactory']['service_script_path']}
  sh installService.sh
  EOHG
  not_if { File.exist?(node['artifactory']['service_init']) }
end

service 'artifactory' do
  action [:start, :enable]
end
