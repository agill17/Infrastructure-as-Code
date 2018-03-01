node.default['grafana'] = {

	'rhel' =>
	{
		'name' => 'grafana-4.6.3-1.x86_64.rpm',
		'rpm_download' => "https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-4.6.3-1.x86_64.rpm",
		'packages' => ['initscripts', 'fontconfig','urw-fonts'],
		'plugins' => {
			'cloudflare-app' => '0.1.2',
			'ns1-app'=>'0.0.5'
		}
	}

}