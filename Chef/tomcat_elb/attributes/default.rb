#####################################################################
#####################################################################
#### =>                   VPC
#####################################################################
#####################################################################

node.default['vpc']={
  
  'name'=> 'tomcat_elb_vpc',
  'cidr' => '10.0.0.0/24',
  'igw' => {
    'name' => 'tomcat_elb_igw'
  },
  
  'pub_rt' => {
    'name' => 'tomcat_elb_pub_rti',
    'routes' => {
      'destination' => '0.0.0.0/0'
    }
  },
  
  'pri_rt' => {
    'name' => 'tomcat_elb_pri_rt'
  },
  
  'pub_subnet' => {
    'name' => 'tomcat_elb_pub_sub'
  }
}



java = nil
case node['platorm_family'] 
  when 'rhel'
    java = 'java-1.7.0-openjdk'
  when 'debian'
    java = 'default-jdk'
end





#####################################################################
#####################################################################
#### =>                   Tomcat 
#####################################################################
#####################################################################

node.default['tomcat']={

  'common' => {
    'dl_link'=>'http://apache.mirrors.ionfish.org/tomcat/tomcat-8/v8.5.24/bin/apache-tomcat-8.5.24.zip',
    'home_dir' => '/opt/tomcat'
  },

  'rhel' => {
    'packages' => %w(#{java}),
    'service_file' => '/etc/systemd/system/tomcat.service',
    'java' => {
      'min'=> '512M',
      'max' => '1024M'
    }
  },

  'debian' => {
    'packages' => %w(#{java})
  }


}