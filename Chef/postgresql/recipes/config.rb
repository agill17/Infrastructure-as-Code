which_pack = nil

case node['platform_family']
	when 'rhel'
		which_pack = 'postgresql-server'
	when 'debian'
		which_pack = 'postgresql-contrib'
end

excute "postgresql-init" do
	user 'root'
	command "postgresql-setup initdb"
	action :nothing
end

package "#{which_pack}" do 
	action :install
	notifies :run, "excute[postgresql-init]", :delayed
end

service "#{which_pack}" do
	action [ :enable, :start ]
end

