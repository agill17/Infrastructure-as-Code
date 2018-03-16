module "2_subnet_vpc" {
  source = "../aws_modules/vpc/generic_public_private_vpc/"
  env= "dev"
  app_name = "tomcat-web-app"
  vpc_name = "tomcat_vpc"
  igw_name = "tomcat_igw"
  num_public_subnets = "2"
  route_table_name = "tomcat_rt"
  sg_name = "tomcat_sg"
}