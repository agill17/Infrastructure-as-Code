module "2_subnet_vpc" {
  source = "../aws_modules/vpc/2_public_subnets_vpc"
  vpc_name = "tomcat_vpc"
  igw_name = "tomcat_igw"
  route_table_name = "tomcat_rt"
  sg_name = "tomcat_sg"
}