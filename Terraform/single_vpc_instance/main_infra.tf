
## VPC
resource "aws_vpc" "vpc" {
  tags = { Name = "main_vpc_terraform" }
  cidr_block = "10.0.0.0/16" ##65K range
  enable_dns_hostnames = true
  enable_dns_support = true
}



########################
#### Public Subnets
########################

resource "aws_subnet" "public_1" {
  tags = { Name = "public_subnet_1" }
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_2" {
  tags = { Name = "public_subnet_2" }
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}




#######################
#### IGW
#######################

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = { Name = "main_igw_terraform" }
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
  tags = { Name = "main-rt-terraform"}
}


resource "aws_route_table_association" "sb_assc_rt-1" {
  route_table_id = "${aws_route_table.public_rt.id}"
  subnet_id = "${aws_subnet.public_1.id}"
}

resource "aws_route_table_association" "sb_assc_rt-2" {
  route_table_id = "${aws_route_table.public_rt.id}"
  subnet_id = "${aws_subnet.public_2.id}"
}




###################
##### SG
###################

resource "aws_security_group" "sg" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {Name = "terrform_sg" ,Type = "Allow_ALL" }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = "${var.sg_ingress_cidr}" 
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = "${var.sg_ingress_cidr}"
  }
}


###################
### Key pair
###################

resource "aws_key_pair" "pub_key_upload" {
  key_name = "${var.key_pair["key_name"]}"
  public_key = "${file("${var.key_pair["local_public_key_path"]}")}"
}



####################
##### EC2
####################

resource "aws_instance" "instance_1" {
  depends_on = ["aws_vpc.vpc", "aws_subnet.public_1", "aws_route_table.public_rt", "aws_key_pair.pub_key_upload", "aws_security_group.sg"]
  ami                    = "${lookup(var.regional_amis, var.default["region"])}"
  instance_type          = "${var.default["type"]}"
  subnet_id              = "${aws_subnet.public_1.id}"
  tags                   = "${var.common_tag}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  key_name               = "${aws_key_pair.pub_key_upload.key_name}"
  provisioner "file" { 
    source = "${var.file["to_copy"]}" 
    destination = "${var.file["to_where"]}"  
  }
  provisioner "remote-exec" {
    inline =["chmod +x ${var.file["to_where"]}", "sh ${var.file["to_where"]}"]
  }
  connection {
    user = "${var.key_pair["ssh_user"]}"
    private_key = "${file("${var.key_pair["local_private_key_path"]}")}"
  }
}


output "public_dns" {
  value = "${aws_instance.instance_1.public_dns}"
}
