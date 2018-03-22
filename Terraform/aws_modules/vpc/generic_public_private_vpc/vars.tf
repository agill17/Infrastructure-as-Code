variable "env" {
  type = "string"
}

variable "app_name" {
  type = "string"
}

# variable "vpc_name" { type = "string"}
variable "vpc_cidr" {
  type = "string"

  default = "10.0.0.0/16"
}

variable "nat_gateway" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}

variable "num_public_subnets" {
  default = "2"
}

variable "num_private_subnets" {
  default = "2"
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

# variable "igw_name" {type = "string"}
# variable "route_table_name" {type = "string" default = "${var.env}-${var.app_name}-route-table"}
# variable "sg_name" {type = "string" default = "${var.env}-${var.app_name}-security-group"}
variable "sg_ingress_from_port" {
  default = 22
}

variable "sg_ingress_to_port" {
  default = 22
}

variable "sg_ingress_protocol" {
  default = "tcp"
}

variable "sg_ingress_cidr_blocks" {
  type = "list"

  default = ["0.0.0.0/0"]
}

variable "sg_egress_from_port" {
  default = 0
}

variable "sg_egress_to_port" {
  default = 0
}

variable "sg_egress_protocol" {
  default = "-1"
}

variable "sg_egress_cidr_blocks" {
  type = "list"

  default = ["0.0.0.0/0"]
}