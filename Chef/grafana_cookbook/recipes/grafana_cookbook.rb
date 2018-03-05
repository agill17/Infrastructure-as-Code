#
# Cookbook:: grafana_cookbook
# Recipe:: grafana_cookbook
#
# Copyright:: 2018, The Authors, All Rights Reserved.


rpm_download = node['grafana']['rhel']['rpm_download']
rpm_download_name = node['grafana']['rhel']['name']
sys_packages = node['grafana']['rhel']['packages']
plugins_required = node['grafana']['rhel']['plugins']

case node['platform']
when 'centos','fedora','redhat'

	package sys_packages

	remote_file 'Download rpm file' do
		source rpm_download
		path "/tmp/#{rpm_download_name}"
	end

	rpm_package 'Install grafana rpm local disk' do
		source "/tmp/#{rpm_download_name}"
		notifies :run, "execute[reload daemon]",:immediately
	end	

	execute 'reload daemon' do
		action :nothing
		command '/bin/systemctl daemon-reload'
	end


	service 'grafana-server' do
		action [:enable, :start]
	end

	plugins_required.each do |name,version|
		grafana_plugin 'cloudflare-app' do
			id name
			version version
			action :install
		end
	end

	ruby_block 'Print info!' do
		block do
			puts "\n"
			puts "**"*50
			puts "Default user name: admin"
			puts "Default password: admin"
			puts "Default port: 3000"
			puts "**"*50
		end
	end

else
	Chef::Log.warn("The #{node['platform']} OS is not supported by this cookbook yet.")

end