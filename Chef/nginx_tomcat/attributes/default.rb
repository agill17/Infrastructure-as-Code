node.default['nginx'] =
{
	"packs" => 
	{
		"pack1" => "epel-release",
		"pack2" => "nginx"
	},
	"ssl" =>
	{
		"dir" => "/etc/ssl/private",
		"certs" => "/etc/ssl/certs/"
	}
}

# node = {
# 	'nginx' =>
# 	{
# 		"install" => 
# 		{
# 			"pack1" => "epel-release",
# 			"pack2" => "nginx"
# 		}
# 	}
# }

# node['nginx']['install'].each do |k,v|
# 	puts v
# end