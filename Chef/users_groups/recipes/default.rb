#
# Cookbook:: users_groups
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


search(:users, "*:*").each do |data_bag|
	user data_bag["id"] do
		comment data_bag["comment"]
		gid data_bag["gid"]
		shell data_bag["shell"]
		home data_bag["home"]
	end
end

## create all groups using data bag!
search(:groups, "*:*").each do |data_bag|
	group data_bag['id'] do
		gid data_bag['gid']
		members data_bag['members']
	end
end	