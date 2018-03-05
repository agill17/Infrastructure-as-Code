#!/bin/bash

CHEF="$HOME/chef-repo"
DATA_BAGS="$CHEF/data_bags"


## only works when data bags are created by knife
## will not work on data bags generated during run time.
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


upload_db
list_on_chef_server