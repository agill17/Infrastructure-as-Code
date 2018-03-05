#
# Cookbook:: nagios_core
# Recipe:: nagios_core
#
# Copyright:: 2017, The Authors, All Rights Reserved.


u_data_bag = search(:users, "id:nagios").first
g_data_bag = search(:groups, "id:nagcmd").first
core_packs = node['nagios']['core']['packs']
nagios_zip = node['nagios']['core']['dl']
nagios_zip_path = node['nagios']['core']['dl_path']
plugins_link = node['nagios']['plugins']['link']
npre_link = node['nagios']['plugins']['npre_link']

core_packs.each { |p| package p }


group g_data_bag['id'] do
	action :create
end

user u_data_bag['id'] do
	action :create
	home u_data_bag['home']
	manage_home u_data_bag['manage_home']
	group u_data_bag['group']
end

bash 'add another group' do
	code <<-EOH
		groupadd nagios
		usermod -a -G nagios nagios
	EOH
	not_if {File.readlines("/etc/group").grep(/nagios/).size > 0}
end

remote_file "Download Nagios Zip File" do
	source nagios_zip
	path nagios_zip_path
end

execute 'unzip file' do
	command "tar xf #{nagios_zip_path} -C #{u_data_bag['home']}"
	not_if { ::Dir.exists?("#{u_data_bag['home']}/#{nagios_zip_path.strip[5..16]}")}
end

bash 'configure before installing' do
	code <<-EOH
	cd #{u_data_bag['home']}/nagios-4.1.1
	./configure
	EOH
end

execute 'run make all command' do
	cwd "#{u_data_bag['home']}/nagios-4.1.1"
	command "make all"
end

## this is TERRIBLE!!!
bash 'run more commands' do
	cwd "#{u_data_bag['home']}/nagios-4.1.1"
	code <<-EOH
	make install
	make install-commandmode
	make install-init
	make install-config
	make install-webconf
	EOH
end

### install nagios plugins
remote_file 'download plugins' do
	path "/tmp/#{plugins_link.strip[35..-1]}"
	source plugins_link
end

execute 'unzip plugins tar' do
	cwd "/tmp"
	command "tar xvf #{plugins_link.strip[35..-1]} -C #{u_data_bag['home']}/nagios-4.1.1/"
	not_if {Dir.exists?("#{u_data_bag['home']}/nagios-4.1.1/#{plugins_link.strip[35..54]}")}
	notifies :run, "bash[more commands mate]", :immediately
end

bash 'more commands mate' do
	action :nothing
	code <<-EOH
		cd #{u_data_bag['home']}/nagios-4.1.1/#{plugins_link.strip[35..54]}
		./configure --with-nagios-user=#{u_data_bag['id']} --with-nagios-group=#{u_data_bag['id']} --with-openssl
		make
		make install
	EOH
end

remote_file 'dowload nrpe plugin' do
	path "/tmp/#{npre_link.strip[67..-1]}"
	source npre_link
end


unzip 'extract the tar file' do
	src "/tmp/#{npre_link.strip[67..-1]}"
	destination "#{u_data_bag['home']}/nagios-4.1.1/"
	not_if_dir_exists "#{u_data_bag['home']}/nagios-4.1.1/nrpe-2.15"
	notifies :run, "bash[configure nrpe plugin]", :immediately	
end

bash 'configure nrpe plugin' do
	cwd "#{u_data_bag['home']}/nagios-4.1.1/nrpe-2.15"
	code <<-EOH
	./configure --enable-command-args --with-nagios-user=#{u_data_bag['id']} --with-nagios-group=#{g_data_bag['id']} \
		--with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
	make all
	make install
	make install-xinetd
	make install-daemon-config
	EOH
end

execute 'add admin user and password for UI' do
	command "htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin password"
	only_if {!File.exists?("/usr/local/nagios/etc/htpasswd.users")}
end

service 'xinetd' do
	action :restart
end