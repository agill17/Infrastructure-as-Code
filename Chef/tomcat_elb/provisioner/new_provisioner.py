from provisioner_class import *
import os

chef = os.environ['HOME']+'/chef-repo'
provisioner = Provisioner(chef)
metadata_file= '/tmp/tomcat_elb_bootstrap_infos.json'




if os.path.isfile(metadata_file):
	os.system('rm -rf %s' % metadata_file)



auto_scale_grp_name = 'tomcat-elb-autoscale-grp'
elb_name='tomcat-elb'
tg_name ='tomcat-servers'
launch_config_name = 'tomcat-launch-config'


all_subnet_ids = provisioner.get_all_subnets_from_chef()
provisioner.create_elb(all_subnet_ids,elb_name)
provisioner.create_elb_target_grp(tg_name)
provisioner.create_elb_listener(tg_name,elb_name)
provisioner.create_launch_config(launch_config_name)
provisioner.create_auto_scaling_group(all_subnet_ids,launch_config_name,tg_name)
ins_ids = provisioner.get_auto_scale_ins_ids(auto_scale_grp_name)
data = provisioner.desc_instances(ins_ids)
provisioner.dump_name_id(data,metadata_file)
