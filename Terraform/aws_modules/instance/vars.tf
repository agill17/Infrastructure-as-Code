variable "env" {
  type = "string"
}

variable "app_name" {
  type = "string"
}

variable "num_instances" {
  default = 1
}

variable "type" {
  default = "t2.medium"
}

variable "ami" {
  default = ""
}

variable "key_name" {
  type = "string"
}

variable "security_groups" {
  type = "list"
}

variable "subnet_id" {
  type = "string"
}

variable "associate_public_ip_address" {
  default = true
}

variable "availability_zone" {
  default = "us-east-1d"
}

# -- not needed unless i plan to add aws_key_pair resource part of this module.
# variable "public_key" { type = "string" description= "path to public key file"}

variable "private_key" {
  type = "string"

  description = "path to private key file"
}

variable "user_data" {
  type        = "string"
  description = "path to userdata file"
}

variable "remote_cmd" {
  default = "pwd"
}
