### single subnet vpc, t2 instance, install ansible on it

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {Name = "ansible_vpc"}
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {Name = "ansible_igw"}
}

resource "aws_subnet" "pub_sub" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.default["az"]}"
  tags = {Name = "ansible_public_subnet"}
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {Name = "ansible_route_table"}
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "rt_sub_associate" {
  route_table_id = "${aws_route_table.rt.id}"
  subnet_id = "${aws_subnet.pub_sub.id}" 
}

resource "aws_security_group" "sg" {
  tags = {Name= "ansible_sg"}
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_security_group_rule" "sg_i" {
  security_group_id = "${aws_security_group.sg.id}"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "sg_e" {
  security_group_id = "${aws_security_group.sg.id}"
  from_port = 0
  to_port = 65350
  protocol = "all"
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}


resource "aws_key_pair" "pub_key" {
  key_name = "${var.ssh["key_name"]}"
  public_key = "${file("${var.ssh["pub_key"]}")}"
}

resource "aws_instance" "ansible_controller" {
  ami = "${lookup(var.regional_amis,var.default["region"])}"
  instance_type = "${var.default["type"]}"
  subnet_id = "${aws_subnet.pub_sub.id}"
  key_name = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  tags = {Name = "ansible_controller", Author = "terraform-amrit"}
  provisioner "file" {
    source = "${var.file["from"]}"
    destination = "${var.file["to"]}"
  }
  provisioner "remote-exec" {
    inline = ["chmod +x ${var.file["to"]}", "sh ${var.file["to"]}"]
  }
  connection {
    user = "${var.ssh["user"]}"
    private_key = "${file("${var.ssh["pri_key"]}")}"
  }
}

resource "aws_eip" "eip" {
  instance = "${aws_instance.ansible_controller.id}" 
  vpc = true 
}


output "Ansible Controller Network Addresses" {
  value = ["${aws_eip.eip.public_ip}"]
}
