#!/bin/bash
# export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin

CHEF_REPO="$HOME/chef-repo"
COOKBOOKS="$CHEF_REPO/cookbooks"
WHICH_COOKBOOK=$1
OLD_VERSION=$2
NEW_VERSION=$3
FIND="version '$2'"
REPLACE="version '$3'"
METADATA=$COOKBOOKS/$WHICH_COOKBOOK/metadata.rb


cookbook_exists(){
	if [ ! -d $COOKBOOKS/$WHICH_COOKBOOK ]
	then
		echo "$WHICH_COOKBOOK DOES NOT EXISTS!!!"
		exit 1
	fi
}

update_metadata(){
	cat $METADATA | grep $3
	if [ $? -eq 0 ]
	then
		echo "Version is up to date: $3"
	else
		sed -iv "s/$FIND/$REPLACE/g" $METADATA
		echo "COOKBOOK: $COOKBOOK : Version Updated: $3"
	fi
}

upload_cookbook(){
	knife cookbook upload $WHICH_COOKBOOK
}

git_push(){
	git add .
	git commit -m "Updated with version $3"
	git push origin $(git rev-parse --abbrev-ref HEAD)
}

cookbook_exists
cd $COOKBOOKS
update_metadata
upload_cookbook
cd $COOKBOOKS/$WHICH_COOKBOOK
git_push
rm -f $COOKBOOKS/$WHICH_COOKBOOK/metadata.rbv
