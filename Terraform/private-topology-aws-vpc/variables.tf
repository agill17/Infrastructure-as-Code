variable "region" {
  default = "us-east-1"
}
variable "awsProfile" {}
variable "vpc" {
  type = object({
    name = string
    cidr = string
    bastion = bool
    azs = list(string)
    tags = map(string)
  })
}