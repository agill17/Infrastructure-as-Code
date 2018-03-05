resource_name :unzip
property :not_if_dir_exists, String
property :src, String
property :destination, String
default_action :run


action :run do

	execute 'run the unzip command' do
		command get_unzip_command(src, destination)
		not_if {Dir.exists?("#{not_if_dir_exists}")}
	end

end