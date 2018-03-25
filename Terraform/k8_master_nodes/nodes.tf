resource "aws_instance" "node_instances" {
  depends_on             = ["module.vpc", "aws_instance.master_instance"]
  ami                    = "${lookup(var.amis,var.default["region"])}"
  instance_type          = "${var.default["type"]}"
  subnet_id              = "${element(module.vpc.public_subnet_ids, count.index)}"
  key_name               = "${aws_key_pair.pub_key.key_name}"
  vpc_security_group_ids = ["${module.vpc.sg_id}"]

  tags = {
    Name = "node-${var.env}-${var.app}"
    Author = "amrit"
  }

  provisioner "file" {
    source      = "${var.file["n_src"]}"
    destination = "${var.file["n_dest"]}"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x ${var.file["n_dest"]}", "sudo sh ${var.file["n_dest"]}"]
  }

  connection {
    private_key = "${file("${var.ssh["pri_key"]}")}"
    user        = "${var.ssh["user"]}"
  }
}