node.default['httpd'] = 
{
	'path' =>
	{
		'httpd.conf' => '/etc/httpd/conf/httpd.conf',
		'sites_available' => '/etc/httpd/sites-available',
		'sites_enabled' => '/etc/httpd/sites-enabled'
	},
	'sites' =>
	{
		'site_1' => '/var/www/site_1',
		'site_2' => '/var/www/site_2',
		'site_3' => '/var/www/site_3'
	},
	'conf_replace'=>
	{
		"Listen 80" => "Listen 127.0.0.1:8080",
		"DocumentRoot \"/var/www/html\"" => "DocumentRoot \"/usr/share/nginx/html/\""
	}
}


node.default['packs'] = ["vim", "epel-release", "nginx", "unzip", "php", "httpd"]

node.default['nginx'] =
{
	'default.conf' => '/etc/nginx/conf.d/',
	'port' => '80',
	'proxy_pass' => "http://127.0.0.1:8080",
	'html' => '/usr/share/nginx/html/opsworks-demo-php-simple-app-version1.zip',
	'app' => 'https://github.com/agill17/opsworks-demo-php-simple-app/archive/version1.zip'
}
