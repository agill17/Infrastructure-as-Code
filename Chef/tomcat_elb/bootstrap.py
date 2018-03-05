import json,os

bootstraps = json.load(open('/tmp/tomcat_elb_bootstrap_infos.json'))
for x in bootstraps:
	key = x['key']
	ip = x['pub_ip']
	node_name = x['name']
	os.system("knife bootstrap %s \
		--sudo \
		-i ~/.ssh/%s.pem --ssh-user ec2-user \
		-N %s -y \
		-r 'role[tomcat_elb]'" % (ip,key,node_name))