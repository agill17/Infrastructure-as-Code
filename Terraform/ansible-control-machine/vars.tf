variable "aws_secret" {}
variable "aws_access" {}


variable "default" {
  default = {
    region = "us-east-1"
    az = "us-east-1a"
    type = "t2.medium"
  }
}


variable "regional_amis" {
  default = {
    centos = "ami-4bf3d731"
  }
}

variable "file" {
  default = {
    from = "install_ansible.sh"
    to = "/tmp/install_ansible.sh"
  }
}



variable "ssh" {
  default = {
    key_name = "ansible_2"
    pub_key = "ansible_2.pub"
    pri_key = "ansible_2.pem"
    user = "centos"
  }
}


