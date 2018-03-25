resource "aws_instance" "master_instance" {
  depends_on             = ["module.vpc", "aws_key_pair.pub_key"]
  ami                    = "${lookup(var.amis,var.default["region"])}"
  instance_type          = "${var.default["type"]}"
  subnet_id              = "${element(module.vpc.public_subnet_ids, count.index)}"
  key_name               = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${module.vpc.sg_id}"]

  tags = {
    Name = "master-${var.env}-${var.app}"
    Author = "amrit"
  }

  provisioner "file" {
    source      = "${var.file["m_src"]}"
    destination = "${var.file["m_dest"]}"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x ${var.file["m_dest"]}", "sudo sh ${var.file["m_dest"]}"]
  }

  connection {
    private_key = "${file("${var.ssh["pri_key"]}")}"
    user        = "${var.ssh["user"]}"
  }
}