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


### welp, ONLY IF  --> maximum number of rules per security group has been reached
data "aws_ip_ranges" "allow_ips_from_default_region_only" {
  regions = ["${var.default["region"]}"]
  services = ["ec2"]
}

resource "aws_security_group" "sg" {
  tags = {Name= "ansible_sg"}
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # cidr_blocks = ["${data.aws_ip_ranges.allow_ips_from_default_region_only.cidr_blocks}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { ## allow all
    from_port = 0 ## because protocol is set to ALL
    to_port = 0 ## because protocol is set to ALL
    protocol = "-1" ## reperesnts ALL
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "pub_key" {
  key_name = "${var.ssh["key_name"]}"
  public_key = "${file("${var.ssh["pub_key"]}")}"
}


resource "aws_iam_role" "ec2_to_s3" {
  name = "ec2S3FullAccess"
  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": "s3:*",
              "Resource": "*"
          }
      ]
    }
  EOF
}

resource "aws_instance" "ansible_controller" {
  ami = "${lookup(var.regional_amis,var.default["region"])}"
  instance_type = "${var.default["type"]}"
  subnet_id = "${aws_subnet.pub_sub.id}"
  key_name = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  tags = {Name = "ansible_controller", Author = "terraform-amrit"}
  iam_instance_profile = "${aws_iam_role.ec2_to_s3.name}"
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


resource "aws_instance" "ansible_node_1" {
  ami = "${lookup(var.regional_amis,var.default["region"])}"
  instance_type = "${var.default["type"]}"
  subnet_id = "${aws_subnet.pub_sub.id}"
  key_name = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  tags = {Name = "ansible_node_1", Author = "terraform-amrit"}
  iam_instance_profile = "${aws_iam_role.ec2_to_s3.name}"
}

resource "aws_instance" "ansible_node_2" {
  ami = "${lookup(var.regional_amis,var.default["region"])}"
  instance_type = "${var.default["type"]}"
  subnet_id = "${aws_subnet.pub_sub.id}"
  key_name = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  tags = {Name = "ansible_node_2", Author = "terraform-amrit"}
  iam_instance_profile = "${aws_iam_role.ec2_to_s3.name}"
}



resource "aws_eip" "eip_main_controller" {
  instance = "${aws_instance.ansible_controller.id}" 
  vpc = true 
}
resource "aws_eip" "eip_node_1" {
  instance = "${aws_instance.ansible_node_1.id}" 
  vpc = true 
}
resource "aws_eip" "eip_node_2" {
  instance = "${aws_instance.ansible_node_2.id}" 
  vpc = true 
}


output "Ansible Controller-Node Network Addresses" {
  value = [
            "Controller: ${aws_eip.eip_main_controller.public_ip}", 
            "Node_1: ${aws_eip.eip_node_1.public_ip}",
            "Node_2: ${aws_eip.eip_node_2.public_ip}"
          ]
}
