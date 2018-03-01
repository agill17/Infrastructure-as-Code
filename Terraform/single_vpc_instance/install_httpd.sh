#!/bin/bash

apt-update -y
apt-get install apache2 git -y
service apache2 start
if [ -d "/var/www/html" ]
then
	cd /var/www/html
	git clone https://github.com/Pinegrow/MrPineCone.git
	service apache2 restart
else
	echo "default apache2 directories missing"
	echo "Is apache2 even installed?"
fi