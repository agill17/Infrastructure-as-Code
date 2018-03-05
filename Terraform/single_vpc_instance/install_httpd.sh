#!/bin/bash

sudo yum install httpd -y
sudo yum install git -y	
sudo service httpd start
if [ -d "/var/www/html" ]
then
	cd /var/www/html
	sudo git clone https://github.com/Pinegrow/MrPineCone.git
	sudo service httpd restart
	sudo service httpd status
	if [ $? -ne 0 ]
	then
		sleep 5
		sudo service httpd start
	fi
else
	echo "default httpd directories missing"
	echo "Is httpd even installed?"
fi