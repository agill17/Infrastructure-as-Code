#!/bin/bash
#archive folder contents if it exceeds a certain number

DATE=$(date +%Y_%m_%d)
DIR=$1
VAR=$(du -sh $DIR | awk '{print $1}')
SUFFIX="M"
LIMIT=150
CURRENT=${VAR%$SUFFIX}

function archive {
	if [ $# -eq 0 ]
    then
    
    	echo "Did not pass any directory name to check for DU"
        exit 1
    
    elif [ $# -eq 1 ] && [ -d $1 ]
    then
        cd /
        if [ $CURRENT -gt $LIMIT ]
        then
        	echo "Current Size of $DIR: $VAR"
            echo "Archieving it now..."
            tar -zcf $DATE.tar.gz $1
        else
           echo "Current $DIR: $VAR"
           echo "LIMIT IS: $LIMIT"
        fi

    else
        echo "what : $1"
    fi
}

archive $1