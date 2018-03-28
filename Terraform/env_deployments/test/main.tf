variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "test-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count      = 3
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.${count.index+1}.0/24"

  tags = {
    Name = "test-public-subent-${count.index+1}"
  }

  map_public_ip_on_launch = true
  availability_zone       = "${element(var.azs, count.index)}"
}

resource "aws_subnet" "private_subnet" {
  count      = 1
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.${count.index+4}.0/24"

  tags = {
    Name = "test-private-subent-${count.index+1}"
  }

  map_public_ip_on_launch = false
  availability_zone       = "${element(var.azs, count.index)}"
}

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "rt_subnet_associate" {
  count          = 3
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  count         = 1
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnets.*.id,count.index)}"
}

resource "aws_security_group" "sg" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "test-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
