import boto3, json, os, subprocess, time, datetime

class Provisioner:

	def __init__(self,chef_repo_dir):
		self.chef_repo = chef_repo_dir
		self.ec2_client = boto3.client('ec2')
		self.ec2_res = boto3.resource('ec2')
		self.elbv2_client = boto3.client('elbv2')
		self.autoscaling_client = boto3.client('autoscaling')
	


	def create_elb_listener(self,target_name, elb_name):
		target_grp_arn=self.desc_elb_target_grps([target_name])
		elb_arn = self.desc_elb([elb_name])
		listener = self.elbv2_client.create_listener(
			LoadBalancerArn=elb_arn,
		    Protocol='HTTP',
	    	Port=80,
			DefaultActions=[
		    {
		        'Type': 'forward',
			     'TargetGroupArn': target_grp_arn
			},
			]
		)



	def dir_exist(self,which_dir):
		if os.path.exists(which_dir):
			return True
		else:
			return False



	def get_all_subnets_from_chef(self,data_bag_dir='data_bags'):
		db_dir = self.chef_repo+'/'+data_bag_dir
		if self.dir_exist(db_dir):
			data_bags = os.listdir(db_dir+'/aws_subnet')
			sub_ids = []
			os.chdir(db_dir+'/aws_subnet')
			for each in data_bags:
				if each.startswith('tomcat-elb') or each.startswith('tomcat_elb'):
					file = json.load(open(each))
					sub_ids.append(file['reference']['id'])
			return sub_ids


	
	def desc_elb(self,names):
		elb_map = {}
		
		elbs = self.elbv2_client.describe_load_balancers(
			Names=names,
		)
		for e in elbs['LoadBalancers']:
			if e.has_key('LoadBalancerArn') and len(e['LoadBalancerArn']) != 0:
				return e['LoadBalancerArn']
				break

	def desc_elb_target_grps(self,names):
		tg_map = {}
		tgs = self.elbv2_client.describe_target_groups(
			Names=names
		)
		for t in  tgs['TargetGroups']:
			if t.has_key('TargetGroupArn'):
				return t['TargetGroupArn']
				break

	def get_auto_scale_ins_ids(self,auto_scaling_grp_name):
		time.sleep(30)
		ins_ids = []
		if auto_scaling_grp_name != None and len(auto_scaling_grp_name) != 0:
			instances = self.autoscaling_client.describe_auto_scaling_groups(
				AutoScalingGroupNames = [ auto_scaling_grp_name ]
			)
			for ins in instances['AutoScalingGroups'][0]['Instances']:
				ins_ids.append(ins['InstanceId'])
		return ins_ids



	def create_elb(self, subnets,name,type='app',region='us-east-1',sg=['sg-c5556eb1']):
		if type == 'app':
			type = 'application'
		else:
			type = 'network'
		elb_creation = self.elbv2_client.create_load_balancer(
			Name=name,
		    Subnets=subnets,
		    SecurityGroups=sg,
		    Scheme='internet-facing',
		    Tags=[
		        {
		            'Key': 'Name',
		            'Value': 'tomcat_elb_elb'
		        },
		    ],
		    Type=type,
		    IpAddressType='ipv4'
		)

	def create_elb_target_grp(self,name):
		target_grp = self.elbv2_client.create_target_group(
			Name=name,
			Protocol='HTTP',
			Port=80,
			VpcId='vpc-935058eb',
		    HealthCheckProtocol='HTTP',
		    HealthCheckPort='80',
		    HealthCheckPath='/var/www/html/index.html',
		    HealthCheckIntervalSeconds=10,
		    HealthCheckTimeoutSeconds=5,
		    HealthyThresholdCount=3,
		    UnhealthyThresholdCount=3,
		    Matcher={
		        'HttpCode': '200'
		    },
		    TargetType='instance'
		)

	def create_elb_listener(self,target_name, elb_name):
		target_grp_arn=self.desc_elb_target_grps([target_name])
		elb_arn = self.desc_elb([elb_name])

		listener = self.elbv2_client.create_listener(
			LoadBalancerArn=elb_arn,
		    Protocol='HTTP',
	    	Port=80,
			DefaultActions=[
		    {
		        'Type': 'forward',
			     'TargetGroupArn': target_grp_arn
			},
			]
		)


	def create_launch_config(self,launch_config_name, default_ami='ami-97785bed',region='us-east-1'):
		launch_config = self.autoscaling_client.create_launch_configuration(
			LaunchConfigurationName=launch_config_name,
		    ImageId=default_ami,
		    KeyName='imac_2018',
		    SecurityGroups=[
		        'sg-c5556eb1'
		    ],
		    InstanceType='t2.micro',
		    InstanceMonitoring={
		        'Enabled': True
		    },
		    AssociatePublicIpAddress=True,
		    UserData="""
		    #!/bin/bash
		 	yum install httpd -y
		 	service httpd start
		 	chkconfig httpd enable
		 	touch /var/www/html/index.html
		 	echo "This is for load balancer Health status because chef recipe is not deploying a tomcat web app yet" > /var/www/html/index.html
		 	service httpd restart
		    """
		)

	def create_auto_scaling_group(self, azs,launch_config_name,tg_name,auto_grp_name='tomcat-elb-autoscale-grp',region='us-east-1'):
		tg_arn = self.desc_elb_target_grps([tg_name])
		azs_spaced_out = ','.join(azs)
		print azs_spaced_out
		aut_group = self.autoscaling_client.create_auto_scaling_group(
			AutoScalingGroupName=auto_grp_name,
		    LaunchConfigurationName=launch_config_name,
		    # InstanceId='string',
		    MinSize=4,
		    MaxSize=4,
		    DefaultCooldown=300,
		    TargetGroupARNs=[
		        tg_arn,
		    ],
		    HealthCheckType='ELB',
		    HealthCheckGracePeriod=300,
		    VPCZoneIdentifier=azs_spaced_out,
		    Tags=[
		        {
		            'Key': 'Name',
		            'Value': 'tomcat-elb-auto-scale',
		            'PropagateAtLaunch': True
		        },
		    ]
		)




	def desc_instances(self, ins_ids,region='us-east-1'):
		ec2 = self.ec2_client
		bootstrap = {}
		all_bootstraps = []
		time.sleep(60)
		ins = ec2.describe_instances(InstanceIds=ins_ids)

		for each_running in ins['Reservations']:
			key = None
			fqdn = None
			name = None
			ins_id = None

			for each in each_running['Instances']:
				key = each['KeyName']
				fqdn = each['PublicDnsName']
				name = each['Tags'][0]['Value']
				ins_id = each['InstanceId']
				pub_ip = each['PublicIpAddress'] 
				break

			bootstrap = {'key':key, 'fqdn':fqdn,'name':name, 'ins_id':ins_id, 'pub_ip':pub_ip}
			all_bootstraps.append(bootstrap)
		print all_bootstraps
		return all_bootstraps



	def create_instance(self,sub_id,name="tomcat_elb",maxx=1,region='us-east-1'):
		ec2_name = name+"{:%Y%m%d%H%M%S}".format(datetime.datetime.now())
		ec2 = boto3.resource('ec2', region_name=region)
		instance = ec2.create_instances(
			ImageId = 'ami-aa2ea6d0',
			MinCount = 1,
			MaxCount = maxx,
			InstanceType = 't2.micro',
			KeyName='imac_2018',
			TagSpecifications=[
				{
					'ResourceType':'instance',
					'Tags':[
						{
							'Key': 'Name',
							'Value':ec2_name
						}
					]
				}
			],
			SubnetId=sub_id
		)
		ins = instance[0]
		ins.wait_until_running()
		ins.load() ## reload
		instances = ins.id
		print "Instance Initliazed %s " % instances
		return instances

			
	def dump_name_id(self,data,where):
		file_2 = open(where,'w')
		json.dump(data, file_2)
