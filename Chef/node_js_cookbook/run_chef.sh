#!/bin/bash

node_name = $1
role = $2

#create instance (ubuntu)
knife ec2 server create  \
-I ami-835b4efa \
-f t2.micro \
-S imac_private_key \
-i $HOME/Downloads/imac_private_key.pem \
--ssh-user ubuntu \
--node-name node_name

#upload role to chef-server
knife role from file "${role}.rb"

#assign role to newely created node 
knife node run_list add $node_name "role[${role}]"

#run chef-client on the new node
knife ssh "name:${node_name}" "sudo chef-client" --ssh-user ubuntu -i $HOME/Downloads/imac_private_key.pem