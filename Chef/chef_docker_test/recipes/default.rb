#
# Cookbook:: chef_docker_test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
require 'chef/provisioning'
with_driver 'docker'

machine 'test' do
  # recipe 'openssh::default'

  machine_options(
    docker_options: {
      base_image: {
        name: 'ubuntu',
        repository: 'ubuntu',
        tag: '16.04'
        },
        :command => '/usr/sbin/sshd -p 8022 -D',

        :env => {
           "deep" => 'purple',
           "led" => 'zeppelin'
        },

        :ports => [8022, "8023:9000", "9500"],

        :volumes => "/tmp",
      },
  )

end