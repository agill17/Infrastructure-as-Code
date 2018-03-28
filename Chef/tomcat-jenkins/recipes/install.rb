


#### all vars



#### install tomcat and toss jenkins war in it

package "tomcat"

bash "change permissions recursively" do
	code <<-EOH
		chmod 777 "#{node['tomcat']['dir']['webapps']}"
		chown -R tomcat:tomcat "#{node['tomcat']['dir']['home']}"
	EOH
	only_if { Dir.exists?(node['tomcat']['dir']['webapps']) && "getent password".include?("tomcat") }
end


remote_file "download jenkins war" do
	source node["jenkins"]["war"]["download"]
	path "#{node['tomcat']['dir']['webapps']}/jenkins.war"
	notifies :restart, "service[tomcat]", :delayed
end


## could use ruby_block and FileEdit methods but for now I dont want to deal with regex for find patterns as well as safe gaurds
execute "update tomcat JAVA_OPTS" do
	tomcat_conf = node['tomcat']['conf']['path']
	command "echo '\"#{node["tomcat"]["conf"]["skip_initial_setup"]}\"' >> #{tomcat_conf}"
	not_if 'cat /etc/tomcat/tomcat.conf | grep runSetupWizard'
end


remote_file "download gradle tarball file" do
	source node["gradle"]["download"]["link"]
	path node["gradle"]["download"]["path"]
end

directory "create gradle home" do
	path node["gradle"]["home"]
	recursive true
	# notifies :run, "execute[unzip]", :immediately
end

execute "unzip" do
	cwd '/tmp'
	command "unzip -o gradle-#{node["gradle"]["version"]}-bin.zip && mv gradle-#{node["gradle"]["version"]}/* #{node["gradle"]["home"]}"
	not_if { Dir.exists?("#{node["gradle"]["home"]}/bin") }
end


link "/opt/gradle/current" do
	to node["gradle"]["home"]
	link_type :symbolic
end

template "set-env-gradle-home" do
	source "bash_profile.erb"
	path "#{ENV['HOME']}/.bash_profile"
end

service "tomcat" do
	action [:enable, :start]
end


ruby_block "notify stdout" do
	block do
		p ""
		p "***************************************************************"
		p "***************************************************************"
		p ""
		p "TOMCAT & JENKINS"
		p "http://#{node['ipaddress']}:8080/jenkins"
		p ""
		p "***************************************************************"
		p "***************************************************************"		
	end
end