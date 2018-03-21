variable "env" {
  type = "string"
}

variable "app_name" {
  type = "string"
}

variable "num_instances" {
  default = 1
}

variable "type" {
  default = "t2.medium"
}

variable "ami" {
  default = ""
}

variable "key_name" {
  type = "string"
}

variable "security_groups" {
  type = "list"
}

variable "subnet_id" {
  type = "string"
}

variable "associate_public_ip_address" {
  default = true
}

variable "availability_zone" {
  default = "us-east-1d"
}

# -- not needed unless i plan to add aws_key_pair resource part of this module.
# variable "public_key" { type = "string" description= "path to public key file"}

variable "private_key" {
  type = "string"

  description = "path to private key file"
}

variable "user_data" {
  type        = "string"
  description = "path to userdata file"
}

variable "remote_cmd" {
  default = "pwd"
}

resource "aws_instance" "ec2" {
  count                       = "${var.num_instances}"
  ami                         = "${var.ami}"
  availability_zone           = "${var.availability_zone}"
  instance_type               = "${var.type}"
  key_name                    = "${var.key_name}"
  security_groups             = "${var.security_groups}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${file("${var.user_data}")}"

  tags = {
    Name = "${var.env}-${var.app_name}-${count.index}"
  }

  provisioner "remote-exec" {
    inline = ["${var.remote_cmd}"]
  }

  connection {
    private_key = "${file("${var.private_key}")}"
    user        = "${var.ssh_user}"
  }
}

output "instance_id" {
  value = "${aws_instance.ec2.*.id}"
}

output "public_dns" {
  value = "${aws_instance.ec2.*.public_dns}"
}

output "public_ip" {
  value = "${aws_instance.ec2.*.public_ip}"
}
