require "json"
module Grafana
	module Helpers

		def list_installed_plugins
			plugins_dir = '/var/lib/grafana/plugins/'
			return ::Dir.entries(plugins_dir).select { |x| x != '..' and x != '.'}
		end

		def plugins_dir_exists?
			if Dir.exists?("/var/lib/grafana/plugins")
				return true
			else
				return false
			end
		end

		def get_plugin_version(plugin_id)
			if plugins_dir_exists? and plugin_installed?(plugin_id) 
				file = JSON.parse(File.read("/var/lib/grafana/plugins/#{plugin_id}/dist/plugin.json"))
				return file['info']['version'].to_s
			end
		end

		def plugin_installed?(plugin_id)
			if plugins_dir_exists?
				all_plugins = list_installed_plugins
				if all_plugins.include?(plugin_id)
					return true
					Chef::Log.warn("The #{plugin_id} plugin is already installed") 

				else
					return false
					Chef::Log.warn("The #{plugin_id} plugin is not installed") 

				end
			end
		end


		def install_plugin(plugin_id,ver)

			if plugin_installed?(plugin_id) and get_plugin_version(plugin_id).to_f < ver.to_f
				return "sudo grafana-cli plugins update #{plugin_id}"
			elsif !plugin_installed?(plugin_id)
				install = "sudo grafana-cli plugins install #{plugin_id}"
				return install
			end

		end


		def remove_plugin(plugin_id)
			if plugin_installed?(plugin_id)
				remove = "sudo grafana-cli plugins remove #{plugin_id}"
				return remove
			end
		end


		def update_all_plugins
			update = "sudo grafana-cli plugins update-all"
			return update
		end

	end
end

Chef::Recipe.include(Grafana::Helpers)
Chef::Resource.include(Grafana::Helpers)