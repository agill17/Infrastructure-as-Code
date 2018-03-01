node.default['gitlab']={

	'install' => {
		'packages' => %w(curl policycoreutils openssh-server openssh-clients postfix),
		'gitlab_sh' => "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh"
	},
	'dl_dir' => '/tmp/dl'

}