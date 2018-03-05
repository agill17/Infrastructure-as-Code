module Unzip

	def unzip_type(src,dest)
		case src
		when /.zip/
			return "unzip -o #{src} -d #{destination_path}"
		when /.gz/
			return "tar -xvf #{src} -C #{destination_path}"
		else
			puts "This type of extension is not supported yet: #{src}"
		end
	end

end

Chef::Recipe.include(Unzip)
Chef::Resource.include(Unzip)
