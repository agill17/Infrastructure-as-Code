#
# Cookbook:: tomcat
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'tomcat::congig' do
  context 'When all attributes are default, on an Ubuntu 16.04' do
    let(:chef_run) do
      # for a complete list of available platforms and versions see:
      # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs java-1.7.0-openjdk-devel' do
      expect(chef_run).to install_package('java-1.7.0-openjdk-devel')
    end

    it 'creates a tomcat group' do
      expect(chef_run).to create_group('tomcat')
    end

    it 'creates tomcat home dir' do
      expect(chef_run).to create_directory('/opt/tomcat')
    end

    it 'creates a tomcat user' do
      expect(chef_run).to create_user('tomcat')
    end

    it 'downloads tomcat tarball file' do
     expect(chef_run).to create_remote_file('/home/vagrant/apache-tomcat-8.5.20.tar.gz')
    end
  end
end
