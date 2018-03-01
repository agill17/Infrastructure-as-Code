resource_name :deploy_artifacts
property :deploy_to, :kind_of => String
property :deploy_from, :kind_of => String
default_action :run

action :run do
	

	directory 'back up directory' do
		path node['tomcat']['artifact']['back_up_dir']
		owner node['tomcat']['user']['name']
		group node['tomcat']['group']
	end

	directory 'sub back up directory' do
		date = get_date
		path "#{node['tomcat']['artifact']['back_up_dir']}//#{date}"
		owner node['tomcat']['user']['name']
		group node['tomcat']['group']
	end

	bash 'backup old artifacts' do
		date = get_date
		code <<-EOH
		if [ -e #{node['tomcat']['artifact']['download_path']}/#{node['tomcat']['artifact']['arti_file_name']} ]
		then
			cp #{node['tomcat']['artifact']['download_path']}/#{node['tomcat']['artifact']['arti_file_name']} #{node['tomcat']['artifact']['back_up_dir']}//#{date} 
		fi
		EOH
	end

	# TODO:
	# remote_file: binaries from either nexus or artifactorty or S3
	remote_file 'download new artifact' do
		path deploy_to
		source deploy_from
	end

end