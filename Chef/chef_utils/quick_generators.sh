#!/bin/bash

# Take positional param for which cookbook
# TODO: generate 1 of each
# recipe
# template
# attribute
# mkdir resources and libraries

## Technically I can do this using a custom generator from chef
## Blah ehh but shell scritps are great!


CHEF="$HOME/chef-repo"
COOKBOOKS="$CHEF/cookbooks"
NEW_COOKBOOK=$1


## generate cookbook
generate_cookbook(){
	if [ ! -d $COOKBOOKS/$NEW_COOKBOOK ]
	then
		cd $COOKBOOKS
		chef generate cookbook $NEW_COOKBOOK
	else
		echo "$NEW_COOKBOOK EXISTS ALREADY!!!!"
		exit 2
	fi
}

generate_recipe(){
	if [ -d $COOKBOOKS/$NEW_COOKBOOK ] && [ ! -e "$COOKBOOKS/$NEW_COOKBOOK/recipes/$NEW_COOKBOOK" ]
	then
		cd $COOKBOOKS/$NEW_COOKBOOK
		chef generate recipe $NEW_COOKBOOK
	fi
}

generate_attribute(){
	if [ -d $COOKBOOKS/$NEW_COOKBOOK ]
	then
		cd $COOKBOOKS/$NEW_COOKBOOK
		chef generate attribute default
	else
		echo "$NEW_COOKBOOK DOES NOT EXISTS!!!"
	fi
}

generate_template(){
	if [ -d $COOKBOOKS/$NEW_COOKBOOK ]
	then
		cd $COOKBOOKS/$NEW_COOKBOOK
		chef generate template default
	else
		echo "$NEW_COOKBOOK DOES NOT EXISTS!!!"
	fi
}

if [ $# -eq 1 ]
then
	echo "--------------- GENERATE $NEW_COOKBOOK COOKBOOK ---------------"
	generate_cookbook
	echo "--------------- GENERATE $NEW_COOKBOOK RECIPE ---------------"
	generate_recipe
	echo "--------------- GENERATE $NEW_COOKBOOK DEFAULT ATTRIBUTE ---------------"
	generate_attribute
	echo "--------------- GENERATE $NEW_COOKBOOK DEFAULT TEMPLATE ---------------"
	generate_template
	echo "--------------- CREATE LIBRARIES DIRECTORY ---------------------"
	mkdir $COOKBOOKS/$NEW_COOKBOOK/libraries
	echo "--------------- CREATE RESOURCES DIRECTORY ---------------------"
	mkdir $COOKBOOKS/$NEW_COOKBOOK/resources
	tree $COOKBOOKS/$NEW_COOKBOOK
fi

