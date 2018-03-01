node.default['nagios'] = {

	'LAMP' => {
		'packs' => %w(httpd mariadb-server mariadb php php-mysql)
	},
	'core' => {
		'packs' => %w(gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel xinetd unzip),
		'dl' => "https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz",
		'dl_path' => "/tmp/nagios-4.1.1.tar.gz",
		'extract_path' => "/home/nagios"
	},
	'plugins' => {
		'link' => "http://nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz",
		'npre_link' => "http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz"
	}

}