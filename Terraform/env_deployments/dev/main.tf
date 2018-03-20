

###########################################################
### vpc, igw, public and private subnets, security group,
### key_pair, ec2
###########################################################

module "vpc" {
  source = "../../aws_modules/vpc/generic_public_private_vpc/"
  env = "${var.env}"
  app_name = "${var.app}" 
  num_public_subnets = 3
}


resource "aws_key_pair" "public_key" {
  key_name = "${var.key_name}"
  public_key = "${file("${var.public_key}")}"
}



#### replace this with aws_autoscaling_group and launch config for test env 
#### because ( why not ) and also change the config management from chef to ansible on test env
#### because ( why not ) 
resource "aws_instance" "ec2" {
  count = 3
  instance_type = "${var.default["type"]}"
  ami = "${lookup(var.amis, var.default["region"])}"
  key_name = "${var.ssh["key_name"]}"
  subnet_id = "${element(module.vpc.public_subnet_ids, count.index)}"
  vpc_security_group_ids = ["${module.vpc.sg_id}"]
  associate_public_ip_address = true
  tags = {Name = "${var.env}-${var.app}-${count.index+1}"}
  provisioner "remote-exec" {
    inline = ["pwd && ls"]
  }
  connection {
    private_key = "${file("${var.ssh["private_key"]}")}"
    user = "${var.ssh["user"]}"
  }

  provisioner "chef" {
    node_name = "${var.env}-${var.app}-${count.index+1}"
    server_url = "https://manage.chef.io/organizations/huh"
    user_name = "${var.ssh["user"]}"
    user_key = "${file("${var.ssh["private_key"]}")}"
    run_list = ["role[tomcat]"]
    prevent_sudo = false
  }
}




output "VPC-INFO" {
  value = [
    "${module.vpc.general}",
    "-----------------------------------------------------",
    "-----------------------------------------------------",
    "VPC ******************************",
    "${module.vpc.vpc}",
    "-----------------------------------------------------",
    "-----------------------------------------------------",
    "Public Subnets ******************************", 
    "${module.vpc.public_subnets}",
    "-----------------------------------------------------",
    "-----------------------------------------------------",
    "Private Subnets ******************************",
    "${module.vpc.private_subnets}"
  ]
}
