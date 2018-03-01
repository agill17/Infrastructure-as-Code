node.default['nagios']=
{
	'packs' => %w(gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel xinetd unzip net-tools),
	'user' => 'nagios',
	'group' => 'nagcmd',
	'dl_link' => 'https://assets.nagios.com/downloads/nagiosxi/5/xi-5.4.3.tar.gz',
	'dl_path' => '/tmp/xi-5.4.3.tar.gz'
}