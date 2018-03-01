cookbook_file 'copy files' do
	action :create
	source 'backup.sh'
	path "#{node['file']['path']}/backup.sh"
end