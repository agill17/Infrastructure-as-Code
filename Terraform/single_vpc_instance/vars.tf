variable "aws_access" {}
variable "aws_secret" {}


variable "default" {
	default = {
		region = "us-east-1"
		type = "t2.micro"
	}

}


// all ubuntu amis
variable "regional_amis" {
  default = {
    us-east-1 = "ami-48c52735"
    us-east-2 = "ami-be96bcdb"
    us-west-1 = "ami-72aba312"
  }
}

variable "key_pair" {
	default = {
		ssh_user = "ubuntu"
		key_name = "terraform_public"
		local_public_key_path = "terraform_public.pub"
		local_private_key_path = "terraform_public"
	}
}

variable "file" {
	default ={
		to_copy = "install_httpd.sh"
		to_where = "/tmp/install_httpd.sh"
	}
}


variable "common_tag"  { default = { Created_By = "Terraform", Author = "Amrit" }}
variable "sg_ingress_cidr" { default = ["0.0.0.0/0"] }
