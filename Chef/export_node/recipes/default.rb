#
# Cookbook:: export_node
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
ruby_block "Save node attributes" do
  block do
    if Dir::exist?('/tmp/kitchen')
      IO.write("/tmp/kitchen/chef_node.json", node.to_json)
    end
  end
end