## VPC
resource "aws_vpc" "vpc" {
  tags = {
    Name = "${var.env}-${var.app_name}-vpc"
  }

  cidr_block           = "${var.vpc_cidr}"             ##65K range
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
}

########################
#### Public Subnets -- Allow 5 for max
########################

resource "aws_subnet" "subnet_public" {
  count                   = "${var.num_public_subnets}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.${count.index+1}.0/24"
  availability_zone       = "${var.azs[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-${var.app_name}-public-${count.index+1}"
  }
}

########################
#### Private Subnet -- Start cidr count at 5 (as many)
########################
resource "aws_subnet" "subnet_private" {
  count                   = "${var.num_private_subnets}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.${count.index+5}.0/24"
  availability_zone       = "${var.azs[count.index]}"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env}-${var.app_name}-private-${count.index+1}"
  }
}

#######################
#### IGW
#######################

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.env}-${var.app_name}-igw"
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
    Name = "${var.env}-${var.app_name}-public-route-table"
  }
}

resource "aws_route_table_association" "sb_assc_rt-1" {
  count          = "${var.num_public_subnets}"
  route_table_id = "${aws_route_table.public_rt.id}"
  subnet_id      = "${element(aws_subnet.subnet_public.*.id, count.index)}"
}

###################
##### NAT
###################

resource "aws_eip" "nat_eip" {
  count = "${var.nat_gateway}"
  vpc   = true

  tags = {
    Name = "${var.env}-${var.app_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = "${var.nat_gateway}"
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.subnet_public.*.id,count.index)}"
}

resource "aws_route_table" "nat_private_rt" {
  count  = "${var.nat_gateway}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags = {
    Name = "${var.env}-${var.app_name}-private-route-table"
  }
}

resource "aws_route_table_association" "priv_sb_assc_rt-1" {
  count          = "${var.num_private_subnets}"
  route_table_id = "${aws_route_table.nat_private_rt.id}"
  subnet_id      = "${element(aws_subnet.subnet_private.*.id, count.index)}"
}

###################
##### SG
###################

resource "aws_security_group" "sg" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.env}-${var.app_name}-security-group"
  }

  ingress {
    from_port   = "${var.sg_ingress_from_port}"
    to_port     = "${var.sg_ingress_to_port}"
    protocol    = "${var.sg_ingress_protocol}"
    cidr_blocks = "${var.sg_ingress_cidr_blocks}"
  }
  ## allow 80 
  ingress {
    from_port   = 80
    to_port     = 80
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

