# tomcat_elb

### Rubocop and Foodcritic tests 
[![Build Status](https://travis-ci.org/agill17/tomcat_aws_provisioning.svg?branch=master)](https://travis-ci.org/agill17/tomcat_aws_provisioning)

_____________________________
## **** Provisioning ****

EC2, ELB, Auto-Scaling: Python Script

VPC: Chef Recipe
_____________________________
## **** Configuration ****

OS: Centos, Ubuntu(not configured yet)

All Configuration in Chef Recipes

_____________________________
## **** Bootstrap and Convergence ****
Automated: Python Script

Run_list: In roles

_____________________________
TODO: 

In `provisioner.py` get the ssh_user and store it in the json file with other metadata and ofcourse refere to it in `bootstrap.py`

There might be an issue with 2 recipes... ( look into that as well )
