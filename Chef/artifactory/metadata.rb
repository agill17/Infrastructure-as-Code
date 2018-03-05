name 'artifactory'
maintainer 'Amrit Gill'
maintainer_email 'amgill1234@gmail.com'
license 'All Rights Reserved'
description 'Installs/Configures artifactory'
long_description 'Installs/Configures artifactory'
issues_url 'https://github.com/agill17/artifactory_cookbook'
source_url 'https://github.com/agill17/artifactory_cookbook'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

supports 'ubuntu', '>= 14.04'

depends 'devops_check_basic'