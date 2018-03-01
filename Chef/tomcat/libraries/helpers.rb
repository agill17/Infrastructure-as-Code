module Tomcat
	module Helpers


		def return_unzip(src,dest)
			case src
			when /.gz/
				return "tar xvf #{src} -C #{dest} --strip-components=1"
			when /.zip/
				return "unzip -o #{src} -d #{dest}"
			else
				puts "file extention not supported: #{node['tomcat']['download']['file_name']}"
			end

		end

		### Might not need this anymore...
		def back_up_old_artifacts
			date = Date.today.strftime('%y_%m_%d')
			if ( !Dir.exists?(node['tomcat']['artifactory']['back_up_dir']) )
				Dir.mkdir(node['tomcat']['artifactory']['back_up_dir'])
				puts "created backup directory for artifacts: #{node['tomcat']['artifactory']['back_up_dir']}"
			else
				puts "Backup directory already exists"
			end


			if (!Dir.exists?("#{node['tomcat']['artifactory']['back_up_dir']}//#{date}"))
				Dir.mkdir("#{node['tomcat']['artifactory']['back_up_dir']}//#{date}")
				puts "created sub directory for artifacts: #{node['tomcat']['artifactory']['back_up_dir']}/#{date}"
				file_utils.cp("#{node['tomcat']['user']['home']}//webapps//#{node['tomcat']['artifactory']['arti_file_name']}","#{node['tomcat']['artifactory']['back_up_dir']}//#{date}")
				puts "artifact backed up in: #{node['tomcat']['artifactory']['back_up_dir']}//#{date}"
			end
		end

		def get_date
			return Date.today.strftime('%y_%m_%d')
		end

	end

end

Chef::Recipe.include(Tomcat::Helpers)
Chef::Resource.include(Tomcat::Helpers)