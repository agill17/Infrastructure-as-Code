
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
