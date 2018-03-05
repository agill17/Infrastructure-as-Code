node.default['rbenv']={
	'packs' => %w(git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel),
	'repo' => {
		'url' => "git://github.com/sstephenson/rbenv.git",
		'branch' => 'master'
	},
	'bash_profile' => {
		'path' => "#{ENV['HOME']}/.bash_profile",
		'update' => {
			'rbenv_path' => "export PATH=#{ENV['HOME']}/.rbenv/bin:$PATH",
			'rbenv_init' => "eval \"\$\(rbenv init \-\)\""
		}
	},
	'ruby-build' => {
		'url' => "git://github.com/sstephenson/ruby-build.git",
		'ruby-build-path' => 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"'
	}
}