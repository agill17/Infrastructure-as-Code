resource "aws_vpc" "vpc_resource" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "amrit-terraform-vpc" }
}

resource "aws_internet_gateway" "igw_resource" {
  vpc_id = "${aws_vpc.vpc_resource.id}"
  tags = { Name = "amrit-terraform-igw" }
}

resource "aws_subnet" "public_sb_resource" {
  vpc_id = "${aws_vpc.vpc_resource.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "pub_rt_resource" {
  vpc_id = "${aws_vpc.vpc_resource.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_resource.id}"
  }
  tags = { Name = "public_route" }
}

resource "aws_route_table" "pri_rt_resource" {
  vpc_id = "${aws_vpc.vpc_resource.id}"
  tags = { Name = "private_route" }
}

resource "aws_route_table_association" "rt_association_resource" {
   subnet_id = "${aws_subnet.public_sb_resource.id}"
   route_table_id = "${aws_route_table.pub_rt_resource.id}"
}

resource "aws_security_group" "sg_resource" {
  vpc_id = "${aws_vpc.vpc_resource.id}"
  tags = "${var.common_tag}"
}

resource "aws_security_group_rule" "sg-rule-resource" {
  security_group_id = "${aws_security_group.sg_resource.id}"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = "${var.sg_ingress_cidr}"
}

resource "aws_instance" "instance_1" {
  ami           = "${lookup(var.regional_amis, var.default_region)}"
  instance_type = "${var.default_type}"
  availability_zone = "${var.default_az}"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.public_sb_resource.id}"
  tags = "${var.common_tag}"
  vpc_security_group_ids = ["${aws_security_group.sg_resource.id}"]
}
