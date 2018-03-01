resource_name :grafana_plugin
property :id, String, required: true
property :version, String, required: true
default_action :install




action :install do

	execute "Install Grafana plugin: #{id}" do
		command install_plugin(id,version)
		not_if { plugin_installed?(id) }
	end
	
end

action :uninstall do

	execute "Uninstall Grafana plugin: #{id}" do
		command remove_plugin(id)
		only_if { plugin_installed?(id) }
		notifies :restart, "service[grafana-server]",:immediately
	end

	service 'grafana-server' do
		action :nothing
	end

end

action :update_all do

	execute "Update All Grafana plugin" do
		command update_all_plugins
	end	

end