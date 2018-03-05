which_java=nil
case node['platform_family']
	when 'rhel' then which_java='java-1.8.0-openjdk-devel'
	when 'debian' then which_java='default-jdk'
end

node.default['required']['packages'] = 
[ 'wget', 'curl', 'tar', 'unzip', 'vim', 'git', 'tree', 'python', 'ruby', which_java]

node.default['required']['memory'] =
{
	'total_min' => 3.5,
	'free_min' => 2.0
}

node.default['required']['connection'] =
{
		'site' => "www.google.com",
		'port' => 80
}

node.default['file']['path'] = '/home'
