###########################################################
### vpc, igw, public and private subnets, security group,
### key_pair, ec2
###########################################################

module "vpc" {
  source              = "../../aws_modules/vpc/generic_public_private_vpc/"
  env                 = "${var.env}"
  app_name            = "${var.app}"
  num_public_subnets  = 3
  num_private_subnets = 2
  nat_gateway         = true
}

resource "aws_key_pair" "public_key" {
  key_name   = "${var.key_name}"
  public_key = "${file("${var.public_key}")}"
}

## install a new chef server and create an org
resource "aws_instance" "chef-server" {
  count                       = 1
  instance_type               = "${var.default["type"]}"
  ami                         = "${lookup(var.amis, var.default["region"])}"
  key_name                    = "${var.ssh["key_name"]}"
  subnet_id                   = "${element(module.vpc.public_subnet_ids, count.index)}"
  vpc_security_group_ids      = ["${module.vpc.sg_id}"]
  associate_public_ip_address = true

  root_block_device {
    volume_type           = "${var.default["root_ebs_type"]}"
    volume_size           = "${var.default["root_ebs_size"]}"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.env}-${var.app}-chef-server"
  }

  provisioner "file" {
    source      = "install_chef_server.sh"
    destination = "/tmp/install_chef_server.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /tmp/install_chef_server.sh", "sudo sh /tmp/install_chef_server.sh"]
  }

  connection {
    private_key = "${file(var.ssh["private_key"])}"
    user        = "${var.ssh["user"]}"
  }
}

#### replace this with aws_autoscaling_group and launch config for test env 
#### because ( why not ) and also change the config management from chef to ansible on test env
#### because ( why not ) 
resource "aws_instance" "ec2" {
  depends_on                  = ["aws_instance.chef-server"]
  count                       = 3
  instance_type               = "${var.default["type"]}"
  ami                         = "${lookup(var.amis, var.default["region"])}"
  key_name                    = "${var.ssh["key_name"]}"
  subnet_id                   = "${element(module.vpc.public_subnet_ids, count.index)}"
  vpc_security_group_ids      = ["${module.vpc.sg_id}"]
  associate_public_ip_address = true

  tags = {
    Name = "${var.env}-${var.app}-chef-node-${count.index+1}"
  }

  root_block_device {
    volume_type           = "${var.default["root_ebs_type"]}"
    volume_size           = "${var.default["root_ebs_size"]}"
    delete_on_termination = true
  }

  provisioner "chef" {
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.ssh["user"]}"
      private_key = "${file("${var.ssh["private_key"]}")}"
    }

    node_name  = "${var.env}-${var.app}-${count.index+1}"
    server_url = "https://manage.chef.io/organizations/huh"
    user_name  = "${var.ssh["user"]}"
    user_key   = "${file("${var.chef_server["key"]}")}"
    run_list   = ["role[tomcat]"]
  }
}
