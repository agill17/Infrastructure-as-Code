#
# Cookbook:: apache2_nginx
# Recipe:: apache2
#
# Copyright:: 2017, The Authors, All Rights Reserved.


httpd_conf = node['httpd']['path']['httpd.conf']
sites_available = node['httpd']['path']['sites_available']
sites_enabled = node['httpd']['path']['sites_enabled']
all_packs = node['packs']

all_packs.each do |pack|
	package pack
end


#### nginx
directory node['nginx']['default.conf'] 

## set nginx proxy pass to httpd on 8080
template "create nginx default conf file" do
	action :create
	source 'default.conf.erb'
	path "#{node['nginx']['default.conf']}/default.conf"
	variables(
		:port => node['nginx']['port'],
		:proxy_pass => node['nginx']['proxy_pass']
	)
end



#### httpd conf
## change defualt port 80 to 8080
## change Document root dir
node['httpd']['conf_replace'].each do |find, replace|
	ruby_block "Find => #{find} && Replace => #{replace}" do
		block do
			file = Chef::Util::FileEdit.new(httpd_conf)
			file.search_file_replace(find, replace)
			file.write_file
		end
		not_if {File.readlines(httpd_conf).include?("#{replace}\n")}
	end
end	

file 'delete old conf file for httpd' do
	user 'root'
	path '/etc/httpd/conf/httpd.conf.old'
	action :delete
end

## create simple html pages
node['httpd']['sites'].each do |site_name, site_folder|
	directory site_folder
	template 'create index file' do
		action :create
		path "#{site_folder}/#{site_name}.html"
		source 'all_sites.html.erb'
		variables(
			:site => site_name
		)
	end
end

execute 'change mode of www folder' do
	command "chmod -R 755 /var/www"
end


## sample php application
## ignoring failure for now because the app does not exists there anymore.
remote_file 'download app.zip' do
	path node['nginx']['html']
	source node['nginx']['app']
	action :create
	ignore_failure true
end


%w(httpd nginx).each do |ser|
	service ser do
		action [:enable, :start]
	end
end
