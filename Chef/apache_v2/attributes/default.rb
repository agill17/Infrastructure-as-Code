node.default['httpd']=
{
	'user' =>
	{
		'name' => 'httpd',
		'home' => '/home/httpd',
		'shell' => '/bin/bash'
	},
	'sites' => 
	{
		'site_1' =>
		{
			'path' => '/var/www/site_1'
		},
		'site_2' =>
		{
			'path' => '/var/www/site_2'
		},
		'site_3' =>
		{
			'path' => '/var/www/site_3'
		}
	},
	'vhost' =>
	{
		'enabled_path' => '/etc/httpd/sites-enabled',
		'available_path' => '/etc/httpd/sites-available'
	}
}

# node = 
# {
# 	'httpd' =>
# 	{
# 		'user' =>
# 		{
# 			'name' => 'httpd',
# 			'home' => '/home/httpd',
# 			'shell' => '/bin/bash'
# 		},
# 		'sites' => 
# 		{
# 			'site_1' =>
# 			{
# 				'path' => '/var/www/site_1'
# 			},
# 			'site_2' =>
# 			{
# 				'path' => '/var/www/site_2'
# 			},
# 			'site_3' =>
# 			{
# 				'path' => '/var/www/site_3'
# 			}
# 		},
# 		'vhost' =>
# 		{
# 			'enabled_path' => '/etc/httpd/sites-enabled',
# 			'available_path' => '/etc/httpd/sites-available'
# 		}
# 	}
# }