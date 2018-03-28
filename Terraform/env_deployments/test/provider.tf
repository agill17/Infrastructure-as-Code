provider "aws" {
  access_key = "${var.aws_access}"
  secret_key = "${var.aws_secret}"
  region     = "us-east-1"
}
