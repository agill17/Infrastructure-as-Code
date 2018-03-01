module Apache
	module Helpers

		def get_apache
			case node['platform']
			when 'ubuntu'
				return 'apache2'
			when 'centos'
				return 'httpd'
			end
		end

	end
end

Chef::Recipe.include(Apache::Helpers)
Chef::Resource.include(Apache::Helpers)