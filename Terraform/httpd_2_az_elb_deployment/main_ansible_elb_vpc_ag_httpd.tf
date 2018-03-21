##########################
#######     VPC
##########################

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc["name"]}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "pub_sub_1" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.default["az_1"]}"

  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "pub_sub_2" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.default["az_2"]}"

  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "route_table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "rt_sub_associate" {
  route_table_id = "${aws_route_table.rt.id}"
  subnet_id      = "${aws_subnet.pub_sub_1.id}"
}

resource "aws_route_table_association" "rt_sub_associate_2" {
  route_table_id = "${aws_route_table.rt.id}"
  subnet_id      = "${aws_subnet.pub_sub_2.id}"
}

##########################
#######     SG
##########################

resource "aws_security_group" "sg" {
  tags = {
    Name = "sg"
  }

  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 0             ## allow all
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    ## allow all
    from_port   = 0             ## because protocol is set to ALL
    to_port     = 0             ## because protocol is set to ALL
    protocol    = "-1"          ## reperesnts ALL
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "pub_key" {
  key_name   = "${var.ssh["key_name"]}"
  public_key = "${file("${var.ssh["pub_key"]}")}"
}

##########################
#######     EC2
##########################

# not sure on how to control output of userdata from terraform
# cannot determine if userdata failed or pass
# hence using provisioner to run things remotely instead of userdata

resource "aws_instance" "instance_1" {
  ami                    = "${lookup(var.amis,var.default["region"])}"
  instance_type          = "${var.default["type"]}"
  subnet_id              = "${aws_subnet.pub_sub_1.id}"
  key_name               = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tags = {
    Name = "instance_1"

    Author = "amrit"
  }

  # user_data = "${file("${var.file["userdata"]}")}" 
  provisioner "file" {
    source      = "${var.file["src"]}"
    destination = "${var.file["dest"]}"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x ${var.file["dest"]}", "sudo sh ${var.file["dest"]}"]
  }

  connection {
    private_key = "${file("${var.ssh["pri_key"]}")}"
    user        = "${var.ssh["user"]}"
  }
}

resource "aws_instance" "instance_2" {
  ami                    = "${lookup(var.amis,var.default["region"])}"
  instance_type          = "${var.default["type"]}"
  subnet_id              = "${aws_subnet.pub_sub_2.id}"
  key_name               = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tags = {
    Name = "instance_2"

    Author = "amrit"
  }

  # user_data = "${file("${var.file["userdata"]}")}"
  provisioner "file" {
    source      = "${var.file["src"]}"
    destination = "${var.file["dest"]}"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x ${var.file["dest"]}", "sudo sh ${var.file["dest"]}"]
  }

  connection {
    private_key = "${file("${var.ssh["pri_key"]}")}"
    user        = "${var.ssh["user"]}"
  }
}

##########################
#######     ALB
##########################

resource "aws_alb" "alb" {
  name               = "${var.alb["name"]}"
  load_balancer_type = "${var.alb["type"]}"
  internal           = false
  subnets            = ["${aws_subnet.pub_sub_1.id}", "${aws_subnet.pub_sub_2.id}"]
  security_groups    = ["${aws_security_group.sg.id}"]

  tags = {
    Name = "${var.alb["name"]}"

    ENV = "DEV"
  }

  ip_address_type = "ipv4"
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.alb["tg_name"]}"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${aws_vpc.vpc.id}"

  # path = "${var.alb["health_check_path"]}"
}

resource "aws_lb_target_group_attachment" "alb_tg_1" {
  target_group_arn = "${aws_lb_target_group.tg.arn}"
  target_id        = "${aws_instance.instance_1.id}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "alb_tg_2" {
  target_group_arn = "${aws_lb_target_group.tg.arn}"
  target_id        = "${aws_instance.instance_2.id}"
  port             = 80
}

### Well, terraform does not support getting ASG instance ips.....rip
# ##########################
# #######  Scale Up Boi
# ##########################
# resource "aws_launch_configuration" "lg" {
#   depends_on = ["aws_alb.alb", "aws_lb_target_group.tg", "aws_lb_target_group_attachment.alb_tg"]
#   name = "AG_Launch_Config"
#   image_id = "${lookup(var.amis,var.default["region"])}"
#   instance_type = "${var.default["type"]}"
#   key_name = "${aws_key_pair.pub_key.key_name}"
#   security_groups = ["${aws_security_group.sg.id}"]
# }

# resource "aws_autoscaling_group" "ag" {
#   depends_on = ["aws_alb.alb", "aws_lb_target_group.tg", "aws_lb_target_group_attachment.alb_tg"]
#   name = "AG"
#   launch_configuration = "${aws_launch_configuration.lg.name}"
#   min_size = 2
#   max_size = 2
#   default_cooldown = 5
#   health_check_grace_period = 350
#   health_check_type = "ELB"
#   target_group_arns = ["${aws_lb_target_group.tg.arn}"]
#   vpc_zone_identifier = ["${aws_subnet.pub_sub_1.id}","${aws_subnet.pub_sub_2.id}"]
# }

## generate dynamic inventory file to push config to nodes 
## ( instead of running playbooks locally on those nodes using remote-exec provisioner)
#data "template_file" "inventory" {
#  template = "${file("inventory")}"
#  vars {
#    node_1 = "${aws_instance.instance_1.public_ip}"
#    node_1 = "${aws_instance.instance_2.public_ip}"
#  }
#}

output "Instanes" {
  value = [
    "Instance_1 ==> ${aws_instance.instance_1.public_ip}/app/slides.html",
    "Instance_2 ==> ${aws_instance.instance_2.public_ip}/app/slides.html",
    "ELB DNS    ==> ${aws_alb.alb.dns_name}",
  ]
}
