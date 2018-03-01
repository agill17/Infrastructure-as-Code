#
# Cookbook:: Gitlab
# Recipe:: Gitlab
#
# Copyright:: 2017, The Authors, All Rights Reserved.



node['gitlab']['install']['packages'].each do |pack|
	package pack
	if pack == 'sshd' or pack == 'postfix'
		service pack do
			action [:start, :enable]
		end
	end
end


directory 'Create a downloads directory' do
	path node['gitlab']['dl_dir']
	mode '00777'
end


remote_file 'Download Gitlab Install Script' do
	source node['gitlab']['install']['gitlab_sh']
	path "#{node['gitlab']['dl_dir']}/script.rpm.sh"
	owner 'root'
	group 'root'
	mode '00555'
	notifies :run, "execute[run gitlab_sh]", :immediately
end

execute 'run gitlab_sh' do
	action :nothing
	cwd node['gitlab']['dl_dir']
	command "sh script.rpm.sh"
end


package 'gitlab-ce' do
	action :install
end



# ruby_block 'Configure gitlab external url' do
# 	action :nothing
# 	block do
# 		find = "external_url 'https://gitlab.example.com'"
# 		replace = "external_url 'https://gitlab.hakase-labs.co'"
# 		file = Chef::Util::FileEdit.new('/etc/gitlab/gitlab.rb')
# 		file.search_file_and_replace(find, replace)
# 		file.write_file
# 	end
# end

# package 'letsencrypt' do
# 	action :install
# 	# notifies :run, "execute[SSL Cert Gen]", :immediately
# end

# execute 'SSL Cert Gen' do
# 	action :nothing
# 	user 'root'
# 	command 'letsencrypt certonly --standalone -d gitlab.hakase-labs.co'
# end

# execute 'gitlab-ctl reconfigure'


package 'firewalld'

service 'firewalld' do
	action [:enable, :start]
end





bash 'open HTTP, HTTPS, SSH' do
	code <<-EOH
	firewall-cmd --permanent --add-service ssh
	firewall-cmd --permanent --add-service http
	firewall-cmd --permanent --add-service https
	firewall-cmd --reload
	EOH
end








