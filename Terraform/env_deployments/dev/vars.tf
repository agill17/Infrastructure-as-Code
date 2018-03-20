variable "aws_access" {}
variable "aws_secret" {}

variable "app" {default = "addressbook"}
variable "env" {default = "dev"}
variable "public_key" {default = "dev.pub"}
variable "private_key" {default = "dev.pem"}
variable "key_name" {default = "dev"}
variable "ssh_user" {default = "centos"}

variable "default" {
  default = {
    region = "us-east-1"
    az = "us-east-1d"
    type = "t2.medium"
  }
}

variable "amis" {
  default = {
    us-east-1 = "ami-4bf3d731"
    us-east-2 = "ami-be96bcdb"
    us-west-1 = "ami-72aba312"
  }
}


variable "ssh" {
  default = {
    private_key = "dev.pem"
    key_name = "dev"
    public_key = "dev.pub"
    user = "centos"
  }
}