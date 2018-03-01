node.default['node_js'] =
{
	'dl_link' =>"https://rpm.nodesource.com/setup_8.x",
	'packs' => 
	{
		'pm2' => '/usr/bin/pm2',
		'http-server' => '/usr/bin/http-server'
	},
	'repo' => 
	{
		'yarn_base_url' => "https://dl.yarnpkg.com/rpm",
		'yarn_gpg_key' => "https://dl.yarnpkg.com/rpm/pubkey.gpg"
	},
	'app' => 
	{
		'dl_link' => "https://github.com/agill17/sample_node_js_app/archive/master.zip",
		'path_to_save' => '/home/vagrant/master.zip',
		'path_to_extract' => '/home/vagrant/app',
		'check_file_exisitance' => '/home/vagrant/app/sample_node_js_app-master/main.js'
	}

}