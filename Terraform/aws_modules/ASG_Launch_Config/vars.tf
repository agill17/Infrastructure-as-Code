variable "env" {
  type = "string"
}

variable "lg_name" {
  default = "lg"
}

variable "lg_image_id" {
  type = "string"
}

variable "lg_instance_type" {
  type = "string"

  default = "t2.medium"
}

variable "lg_key_name" {
  type = "string"
}

variable "lg_security_group_ids" {
  type = "list"

  default = []
}

variable "asg_name" {
  default = "lg"
}

variable "asg_min_instances" {
  default = 1
}

variable "asg_max_instances" {
  default = 1
}

variable "asg_default_cooldown" {
  default = 5
}

variable "asg_health_check_grace_period" {
  default = 350
}

variable "asg_health_check_type" {
  default = "EC2"
}

variable "asg_subnet_ids" {
  type = "list"
}