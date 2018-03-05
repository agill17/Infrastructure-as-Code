resource_name :unzip
property :src, String
property :dest, String
default_action :run

tomcat_home = node['tomcat']['home']['path']

action :run do
	
	directory 'create dest directory' do
		action :create
		path dest
	end

	execute "Extract #{src} to #{dest}" do
		command return_unzip(src,dest)
		not_if { Dir.exists?("#{tomcat_home}/webapps") }
	end

end