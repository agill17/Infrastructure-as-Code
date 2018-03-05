#
# Cookbook:: RoR_MySQL
# Recipe:: RoR_setup
#
# Copyright:: 2017, The Authors, All Rights Reserved.


################################
##### Node Attributes
rbenv_packs = node['rbenv']['packs']
rbenv_git_url = node['rbenv']['repo']['url']
rbenv_path = "#{ENV['HOME']}/.rbenv"
rbenv_bash_path = node['rbenv']['bash_profile']['path']
rbenv_path_bash_profile = node['rbenv']['bash_profile']['update']['rbenv_path']
rbenv_init_path_bash_profile = node['rbenv']['bash_profile']['update']['rbenv_init']
ruby_build_url = node['rbenv']['ruby-build']['url']
ruby_build_path = node['rbenv']['ruby-build']['ruby-build-path']
################################



### install all packs for rbenv
rbenv_packs.each do |pack|
	package pack
end	


### clone rbenv repo mate
git 'clone rbenv repo' do
	action :sync
	repository rbenv_git_url
	destination rbenv_path
end


execute 'ran rbenv rehash when needed' do
	action :nothing
	command 'rbenv rehash'
end

ruby_block 'insert rbenv_path' do
	block do
		file = Chef::Util::FileEdit.new(rbenv_bash_path)
		file.insert_line_if_no_match(rbenv_path_bash_profile, rbenv_path_bash_profile)
		file.write_file
	end
	not_if {File.readlines(rbenv_bash_path).grep(/.rbenv\/bin/).any?}
end

ruby_block 'insert rbenv init command' do
	block do
		file = Chef::Util::FileEdit.new(rbenv_bash_path)
		file.insert_line_if_no_match(rbenv_init_path_bash_profile, rbenv_init_path_bash_profile)
		file.write_file
	end
	not_if {File.readlines(rbenv_bash_path).grep(/rbenv init/).any?}
end

execute 'run shell' do
	action :nothing
	command 'exec $SHELL'
end

### clone ruby-build repo mate
git 'clone ruby-build' do
	action :sync
	repository ruby_build_url
	destination "#{ENV['HOME']}/.rbenv/ruby-build"
end

### update bash_profile
bash 'update bash profile for ruby-build' do
	code <<-EOH
		echo "#{ruby_build_path}" >> #{node['rbenv']['bash_profile']['path']}
	EOH
	not_if {File.readlines(node['rbenv']['bash_profile']['path']).grep(/ruby_build_path/).size > 0}
	notifies :run, "execute[run shell]", :immediately
end


file 'add gemrc contents' do
	path "#{ENV['HOME']}/.gemrc"
	content 'gem: --no-document'
end


%w(bundler rails).each do |pac|
	gem_package "#{pac}" do 
		action :install
		notifies :run, "execute[ran rbenv rehash when needed]", :immediately
	end
end


=begin

Whenever you install a new version of Ruby or a gem that provides commands,
you should run the rehash sub-command. (rbenv rehash)
This will install shims for all Ruby executables known to rbenv, 
which will allow you to use the executables:
	
=end





