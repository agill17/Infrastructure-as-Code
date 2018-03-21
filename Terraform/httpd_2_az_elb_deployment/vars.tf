variable "aws_access" {}
variable "aws_secret" {}

variable "env" { default = "dev" }
variable "app" { default = "httpd"}
variable "vpc" {
  default = {
    name = "vpc"
  }
}

variable "default" {
  default = {
    region = "us-east-1"
    az_1   = "us-east-1a"
    az_2   = "us-east-1b"
    type   = "t2.medium"
  }
}

variable "ssh" {
  default = {
    user     = "centos"
    key_name = "test"
    pub_key  = "test.pub"
    pri_key  = "test.pem"
  }
}

variable "alb" {
  default = {
    name              = "alb"
    type              = "application"
    tg_name           = "tg"
    health_check_path = "/index.html"
  }
}

variable "amis" {
  default = {
    us-east-1 = "ami-4bf3d731"
    us-east-2 = "ami-be96bcdb"
    us-west-1 = "ami-72aba312"
  }
}

variable "file" {
  default = {
    userdata = "userdata.sh"
    src      = "userdata.sh"
    dest     = "/tmp/userdata.sh"
  }
}
