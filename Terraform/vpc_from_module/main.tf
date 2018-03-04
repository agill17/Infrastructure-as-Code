module "simple_vpc" {
  source = "../aws_modules/vpc/"
  vpc_name = "module_vpc_name"
  subnet_name = "module_subnet_name"
  igw_name = "module_igw"
  route_table_name = "module_rt"
  subnet_name = "module_subnet"
  subnet_az = "us-east-1a"
  sg_name = "module_sg"
  sg_ingress_protocol = "tcp"
  sg_ingress_cidr_blocks =  ["0.0.0.0/0"]
}

output "vpc_output" {
  value = "${module.simple_vpc.output}"
}