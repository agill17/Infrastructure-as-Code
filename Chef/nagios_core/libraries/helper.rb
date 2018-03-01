module Helpers

	def get_unzip_command(src, dest)
		case src
		when /.gz/
			return "tar xvf #{src} -C #{dest}"
		when /.zip/
			return "unzip -o #{src} -d #{dest}"
		end
	end

end

Chef::Recipe.include(Helpers)
Chef::Resource.include(Helpers)