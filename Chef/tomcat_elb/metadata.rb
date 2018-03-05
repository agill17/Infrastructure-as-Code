name 'tomcat_elb'
maintainer 'Amrit Gill'
maintainer_email 'amgill1234@gmail.com'
license 'All Rights Reserved'
description 'Installs/Configures tomcat_elb'
long_description 'Installs/Configures tomcat_elb'
issues_url 'https://github.com/agill17/tomcat_elb'
source_url 'https://github.com/agill17/tomcat_elb'
version '0.1.0'

supports 'centos'

chef_version '>= 12.1' if respond_to?(:chef_version)

depends "devops_check_basic"

