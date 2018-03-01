resource_name :unzip
property :src, String
property :dest, String
property :not_if_dir_exists, String
default_action :run



action :run do

	package 'unzip'

	execute "#This will unzip" do
		command unzip_type(src,dest)
		not_if { Dir.exists?("#{not_if_dir_exists}")}
	end

end