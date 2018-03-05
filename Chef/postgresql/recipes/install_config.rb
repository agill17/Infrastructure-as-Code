pack = nil
case node['platform_family']
when 'rhel'
	pack = "postgresql-server"
when 'debain'
	pack = "postgresql-contrib"
end

package "#{pack}"  do	
	action :install
	notifies :run, "execute[postgresql-init]"
end

execute "postgresql-init" do
	command "postgresql-setup initdb"
	action :nothing
end

service "postgresql" do
	action [ :enable, :start ]
end