##########################
#######     VPC
##########################

module "vpc" {
  source              = "../aws_modules/vpc/generic_public_private_vpc"
  env                 = "${var.env}"
  app_name            = "${var.app}"
  num_public_subnets  = 3
  num_private_subnets = 3
  nat_gateway         = true
}

resource "aws_key_pair" "pub_key" {
  key_name   = "${var.ssh["key_name"]}"
  public_key = "${file("${var.ssh["pub_key"]}")}"
}
