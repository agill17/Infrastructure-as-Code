##########################
#######     VPC
##########################

module "vpc" {
  source              = "../aws_modules/vpc/generic_public_private_vpc"
  env                 = "${var.env}"
  app_name            = "${var.app}"
  num_public_subnets  = 3
  num_private_subnets = 3
  nat_gateway         = true
}

resource "aws_key_pair" "pub_key" {
  key_name   = "${var.ssh["key_name"]}"
  public_key = "${file("${var.ssh["pub_key"]}")}"
}

##########################
#######     EC2
##########################

### put all in public subnets
resource "aws_instance" "instances" {
  depends_on             = ["module.vpc", "aws_key_pair.pub_key"]
  count                  = 2
  ami                    = "${lookup(var.amis,var.default["region"])}"
  instance_type          = "${var.default["type"]}"
  subnet_id              = "${element(module.vpc.public_subnet_ids, count.index)}"
  key_name               = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${module.vpc.sg_id}"]

  tags = {
    Name = "${var.env}-${var.app}-instance-${count.index+1}"
    Author = "amrit"
  }

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


#### TODO: Need to figure out how to add targets with count
##########################
#######     ALB
##########################

# resource "aws_alb" "alb" {
#   depends_on         = ["aws_instance.instances"]
#   name               = "${var.alb["name"]}"
#   load_balancer_type = "${var.alb["type"]}"
#   internal           = false
#   subnets            = ["${module.vpc.public_subnet_ids}"]
#   security_groups    = ["${module.vpc.sg_id}"]

#   tags = {
#     Name = "${var.alb["name"]}"

#     ENV = "${var.env}"
#   }

#   ip_address_type = "ipv4"
# }

# resource "aws_lb_target_group" "tg" {
#   depends_on  = ["aws_alb.alb"]
#   name        = "${var.alb["tg_name"]}"
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "instance"
#   vpc_id      = "${module.vpc.vpc_id}"

#   health_check {
#     path = "${var.alb["health_check_path"]}"
#     interval = 10
#     healthy_threshold = 2
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_target_group_attachment" "targets" {
#   depends_on = ["aws_lb_target_group.tg"]
#   count = 2
#   target_group_arn = "${aws_lb_target_group.tg.arn}"
#   target_id = "${element(aws_instance.instances.*.id, count.index)}"
# }

# resource "aws_lb_target_group_attachment" "alb_tg_1" {
#   target_group_arn = "${aws_lb_target_group.tg.arn}"
#   target_id        = "${aws_instance.instance_1.id}"
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "alb_tg_2" {
#   target_group_arn = "${aws_lb_target_group.tg.arn}"
#   target_id        = "${aws_instance.instance_2.id}"
#   port             = 80
# }

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

# output "Instanes" {
#   value = [
#     "Instance_1 ==> ${aws_instance.instance_1.public_ip}/app/slides.html",
#     "Instance_2 ==> ${aws_instance.instance_2.public_ip}/app/slides.html",
#     "ELB DNS    ==> ${aws_alb.alb.dns_name}",
#   ]
# }
