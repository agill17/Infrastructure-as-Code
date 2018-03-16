module "simple_vpc" {
  source = "../aws_modules/vpc/generic_public_private_vpc/"
  env = "dev"
  app_name = "test_app"
  vpc_name = "module_vpc_name"
  igw_name = "module_igw"
  num_public_subnets = 3
  num_private_subnets = 3
  route_table_name = "module_rt"
  sg_name = "module_sg"
  sg_ingress_protocol = "tcp"
  sg_ingress_cidr_blocks =  ["0.0.0.0/0"]
}
