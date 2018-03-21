variable "aws_access" {}
variable "aws_secret" {}

variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "default" {
  default = {
    region             = "us-east-1"
    type               = "t2.micro"
    env                = "dev"
    app_name           = "httpd"
    num_public_subnets = 2
  }
}

// first ami is amazon linux image
variable "regional_amis" {
  default = {
    us-east-1 = "ami-97785bed"
    us-east-2 = "ami-be96bcdb"
    us-west-1 = "ami-72aba312"
  }
}

variable "key_pair" {
  default = {
    ssh_user               = "ec2-user"
    key_name               = "terraform_public"
    local_public_key_path  = "terraform_public.pub"
    local_private_key_path = "terraform_public"
  }
}

variable "file" {
  default = {
    to_copy  = "install_httpd.sh"
    to_where = "/tmp/install_httpd.sh"
  }
}

variable "common_tag" {
  default = {
    Created_By = "Terraform"

    Author = "Amrit"
  }
}

variable "sg_ingress_cidr" {
  default = ["0.0.0.0/0"]
}
