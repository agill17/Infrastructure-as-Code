locals {
  commonNameTag = {
    "VPC" : var.vpc.name
  }
}

locals {
  tags = merge(local.commonNameTag, var.vpc.tags)
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc.cidr
  tags = local.tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = local.tags
}

resource "aws_eip" "nateip" {
  vpc = true
  tags = local.tags
}


resource "aws_route_table" "publicRt" {
  vpc_id = aws_vpc.myvpc.id
  tags = merge(local.tags, map("Name", "public-rt"))
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "publicSubnet" {
  vpc_id = aws_vpc.myvpc.id
  tags = merge(local.tags, map("Name", "public-subnet"))
  cidr_block = "10.0.1.0/24"
}

resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.publicSubnet.id
  tags = local.tags
  allocation_id = aws_eip.nateip.id
}

resource "aws_route_table_association" "publicRtPublicSubnet" {
  route_table_id = aws_route_table.publicRt.id
  subnet_id = aws_subnet.publicSubnet.id
}

resource "aws_route_table" "privateRts" {
  count = length(var.vpc.azs)
  vpc_id = aws_vpc.myvpc.id
  tags = merge(local.tags, map("Name", "private-rt-${count.index+1}"))
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_subnet" "privateSubnets" {
  count = length(var.vpc.azs)
  vpc_id = aws_vpc.myvpc.id
  tags = merge(local.tags, map("Name", "private-subnet-${count.index+1}"))
  cidr_block = "10.0.${count.index+5}.0/24"
  availability_zone = var.vpc.azs[count.index]
}

resource "aws_route_table_association" "privateRTPrivateSubnet" {
  count = length(var.vpc.azs)
  route_table_id = aws_route_table.privateRts[count.index].id
  subnet_id = aws_subnet.privateSubnets[count.index].id
}