#!/bin/bash

sudo apt install apache2 -y
sudo apt install git -y	
sudo service apache2 start
if [ -d "/var/www/html" ]
then
	cd /var/www/html
	git clone https://github.com/Pinegrow/MrPineCone.git
	sudo service apache2 restart
else
	echo "default apache2 directories missing"
	echo "Is apache2 even installed?"
fi