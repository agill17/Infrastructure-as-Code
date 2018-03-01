#
# Cookbook:: jenkins
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'jenkins::master' do
  # context 'centos' do
  #   let(:chef_run) do
  #     # for a complete list of available platforms and versions see:
  #     # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
  #     runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.2')
  #     runner.converge(described_recipe)
  #   end

  #   it 'converges successfully' do
  #     expect { chef_run }.to_not raise_error
  #   end

  #   it 'installs java' do
  #     expect(chef_run).to install_package('java-1.8.0-openjdk-devel')
  #   end
  # end

  context 'Ubuntu 16.04' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'installs java' do
      expect(chef_run).to install_package('default-jdk')
    end
    
    it 'creates jenkins group' do
      expect(chef_run).to create_group('jenkins')
    end

    it 'creates jenkins user' do
      expect(chef_run).to create_user('jenkins')
    end

    it 'adds jenkins to apt repo' do
      expect(chef_run).to add_apt_repository('jenkins')
    end

    it 'installs jenkins from package manager' do
      expect(chef_run).to install_package('jenkins')
    end


    it 'edits jenkins conf file on deb' do
      expect(chef_run).to create_template('/etc/default/jenkins')
    end


  end
end

