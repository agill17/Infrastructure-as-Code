variable "aws_access" {}
variable "aws_secret" {}
variable "default_region" {  default = "us-east-1" }
variable "default_az" { default = "us-east-1a" }
variable "default_type" { default = "t2.micro" }
variable "regional_amis" {
  type = "map" 
  default = {
    us-east-1 = "ami-48c52735"
    us-east-2 = "ami-be96bcdb"
    us-west-1 = "ami-72aba312"
  }
}
