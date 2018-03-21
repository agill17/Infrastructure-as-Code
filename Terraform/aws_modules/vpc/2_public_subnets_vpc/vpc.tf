variable "vpc_name" {
  type = "string"
}

variable "vpc_cidr" {
  type = "string"

  default = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}

variable "subnet_1" {
  type = "map"

  default = {
    name        = "public_subnet_1"
    az          = "us-east-1a"
    subent_cidr = "10.0.1.0/24"
  }
}

variable "subnet_2" {
  type = "map"

  default = {
    name        = "public_subnet_2"
    az          = "us-east-1b"
    subent_cidr = "10.0.2.0/24"
  }
}

variable "igw_name" {
  type = "string"
}

variable "route_table_name" {
  type = "string"
}

variable "sg_name" {
  type = "string"
}

variable "sg_ingress_from_port" {
  default = 22
}

variable "sg_ingress_to_port" {
  default = 22
}

variable "sg_ingress_protocol" {
  default = "tcp"
}

variable "sg_ingress_cidr_blocks" {
  type = "list"

  default = ["0.0.0.0/0"]
}

variable "sg_egress_from_port" {
  default = 0
}

variable "sg_egress_to_port" {
  default = 0
}

variable "sg_egress_protocol" {
  default = "-1"
}

variable "sg_egress_cidr_blocks" {
  type = "list"

  default = ["0.0.0.0/0"]
}

## VPC
resource "aws_vpc" "vpc" {
  tags = {
    Name = "${var.vpc_name}"
  }

  cidr_block           = "${var.vpc_cidr}"             ##65K range
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
}

########################
#### Public Subnet
########################

resource "aws_subnet" "public_1" {
  tags = {
    Name = "${var.subnet_1["name"]}"
  }

  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_1["subent_cidr"]}"
  availability_zone       = "${var.subnet_1["az"]}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_2" {
  tags = {
    Name = "${var.subnet_2["name"]}"
  }

  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.subnet_2["subent_cidr"]}"
  availability_zone       = "${var.subnet_2["az"]}"
  map_public_ip_on_launch = true
}

#######################
#### IGW
#######################

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.igw_name}"
  }
}

######################
#### Route Table
######################

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "${var.route_table_name}"
  }
}

resource "aws_route_table_association" "sb_assc_rt-1" {
  route_table_id = "${aws_route_table.public_rt.id}"
  subnet_id      = "${aws_subnet.public_1.id}"
}

###################
##### SG
###################

resource "aws_security_group" "sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.sg_name}"
  }

  ingress {
    from_port   = "${var.sg_ingress_from_port}"
    to_port     = "${var.sg_ingress_to_port}"
    protocol    = "${var.sg_ingress_protocol}"
    cidr_blocks = "${var.sg_ingress_cidr_blocks}"
  }

  egress {
    from_port   = "${var.sg_egress_from_port}"
    to_port     = "${var.sg_egress_to_port}"
    protocol    = "${var.sg_egress_protocol}"
    cidr_blocks = "${var.sg_egress_cidr_blocks}"
  }
}

output "output" {
  value = [
    "VPC_ID: ${aws_vpc.vpc.id}",
    "VPC_CIDR: ${aws_vpc.vpc.cidr_block}",
    "-------------------------------------------------------",
    "SUBNET_ID: ${aws_subnet.public_1.id}",
    "CIDR: ${aws_subnet.public_1.cidr_block}",
    "AZ: ${aws_subnet.public_1.availability_zone}",
    "-------------------------------------------------------",
    "IGW_ID: ${aws_internet_gateway.igw.id}",
    "-------------------------------------------------------",
    "ROUTE_TABLE_ID: ${aws_route_table.public_rt.id}",
    "-------------------------------------------------------",
    "SECURITY_GROUP_ID: ${aws_security_group.sg.id}",
  ]
}
