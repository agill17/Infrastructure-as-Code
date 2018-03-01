variable "aws_access" {}
variable "aws_secret" {}
variable "default_region" {  default = "us-east-1" }
variable "default_az" { default = "us-east-1a" }
variable "default_type" { default = "t2.micro" }

// all ubuntu amis
variable "regional_amis" {
  default = {
    us-east-1 = "ami-48c52735"
    us-east-2 = "ami-be96bcdb"
    us-west-1 = "ami-72aba312"
  }
}

variable "ssh_user" {default = "ubuntu"}
variable "inline_cmds" { default =
		["chmod +x /tmp/install_httpd", "sh /tmp/install_httpd"]
}

variable "common_tag"  { default = { Created_By = "Terraform", Author = "Amrit" }}
variable "sg_ingress_cidr" { default = ["0.0.0.0/0"] }


### aws_key_pair
variable "key_name" { default = "terraform_public.pub" }
variable "public_key_path" { default = "terraform_public.pub" }
variable "private_key_path" { default = "terraform_public"}




variable "local_file" { default = "files/install_httpd.sh" }
variable "dest_path" { default = "/tmp/install_httpd.sh"}