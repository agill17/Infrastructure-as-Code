resource "aws_vpc" "vpc_resource" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "amrit-terraform-vpc" }
}



resource "aws_internet_gateway" "igw_resource" {
  vpc_id = "${aws_vpc.vpc_resource.id}"
  tags = { Name = "amrit-terraform-igw" }
}



resource "aws_route_table" "pub_rt_resource" {
  vpc_id = "${aws_vpc.vpc_resource.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_resource.id}"
  }
  tags = { Name = "public_route" }
}


resource "aws_subnet" "public_sb_resource" {
  vpc_id = "${aws_vpc.vpc_resource.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
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
  from_port = 0
  to_port = 65535
  protocol = "TCP"
  cidr_blocks = "${var.sg_ingress_cidr}"
}


// takes your pub key and dumps in ec2 key-pairs
// can further use logical resource id to call the key_name when provisioning instance
resource "aws_key_pair" "pub_key_resource" {
  key_name = "${var.key_pair["key_name"]}"
  public_key = "${file("${var.key_pair["local_public_key_path"]}")}"
}


 // install apache2 and deploy a sample website
resource "aws_instance" "instance_1" {
  ami                    = "${lookup(var.regional_amis, var.default["region"])}"
  instance_type          = "${var.default["type"]}"
  subnet_id              = "${aws_subnet.public_sb_resource.id}"
  tags                   = "${var.common_tag}"
  vpc_security_group_ids = ["${aws_security_group.sg_resource.id}"]
  key_name               = "${aws_key_pair.pub_key_resource.key_name}"
  associate_public_ip_address = true
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