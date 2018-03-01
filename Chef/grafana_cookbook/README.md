# grafana_cookbook


### OS Tested : Centos 7
__________


Installs a sample Grafana Dashboard for Centos systems with the ability to install plugins using node attributes


#### Custom Resources:
______________________
* ##### grafana_plugin

	*** DOES NOT SUPPORT INSTALLING FROM EXTERNAL_URL YET! ***
	* Default action: install
	* Actions: uninstall, update_all, install
	* Property: id => name of plugin, *REQUIRED*
	* Property: version => version of plugin, *REQUIRED*


###### Sample Dashboard
![alt text](https://github.com/agill17/Grafana_cookbook/blob/master/Screen%20Shot%202018-01-26%20at%201.16.37%20AM.png)
