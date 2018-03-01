#
# Cookbook:: devops_check_basic
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


sys_total_mem = node['memory']['total'].to_f
sys_free_mem = node['memory']['free'].to_f
sys_total_mem /= 1024 * 1024
sys_free_mem /=  1024 * 1024
min_free = node['required']['memory']['free_min']
min_total = node['required']['memory']['total_min']
site = node['required']['connection']['site']
port = node['required']['connection']['port']


## check total memory
if (sys_total_mem < min_total)
	Chef::Log.fatal("
	--------------------------------------------------
	FATAL:
	Total Memory: #{sys_total_mem}
	Required Total Memory: #{min_total}
	--------------------------------------------------")
end

#check free memory
if (sys_free_mem < min_free ) 
	Chef::Log.fatal("
	--------------------------------------------------
	FATAL:
	Total Free Memory: #{sys_free_mem}
	Required Free Memory: #{min_free}
	--------------------------------------------------")
end

## check internet connection
ruby_block 'check connection' do
	block do
		Chef::Log.fatal 'connections refused!'.upcase
    end
    not_if "ping -c3 #{site}"
end