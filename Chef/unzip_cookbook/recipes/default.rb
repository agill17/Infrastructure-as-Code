#
# Cookbook:: unzip
# Recipe:: default
#
# Copyright:: 2017, Some random college kid, All Rights Reserved.

unzip "Unzip dir" do
	action :run
	src node['unzip']['src']
	dest node['unzip']['destination_path']
	not_if_dir_exists "#{node['unzip']['destination_path']}"
end