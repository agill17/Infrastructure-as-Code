#!/bin/bash

CHEF="$HOME/chef-repo"
ENV='all_envs.txt'
ROLES='roles/*.rb'
DATA_BAGS="$CHEF/data_bags"

upload_db(){
	for i in $(ls $DATA_BAGS); do
		knife data bag from file $i $(ls $DATA_BAGS/$i)
	done
}



list_on_chef_server(){
	cd $CHEF
	echo "-------------------- Current Chef Server Data Bags --------------------"
	knife data bag list
}



upload_all_cookbooks(){
	echo "=============== Uploading required cookbooks ==============="
	for x in $(ls "$CHEF/cookbooks"); do
		knife cookbook upload $x
	done
echo "=============== All cookbooks successfully uploaded! ==============="
}


upload_all_envs(){
	echo "=============== Uploading all envrionments all_envs.txt ==============="
	for i in $(cat $ENV); do
 		if [ -e $i.rb ]
 		then
    		knife environment from file $i".rb"
 		else
 			echo "$i.rb does not exist in ${HOME}/chef-repo" 
 		fi
	done
echo "=============== All ENV successfully uploaded! ==============="

}

upload_all_roles(){
	## upload all roles
	echo "=============== Uploading all roles in roles/ directory ==============="
	for i in $(ls $ROLES); do
		knife role from file $i
	done
	echo "=============== All Roles sucessfully uploaded! ==============="
}

cd $CHEF
pwd
export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin
upload_db
upload_all_cookbooks
upload_all_envs
upload_all_roles




