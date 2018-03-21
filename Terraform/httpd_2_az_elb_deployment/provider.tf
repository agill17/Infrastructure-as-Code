provider "aws" {
  secret_key = "${var.aws_secret}"
  access_key = "${var.aws_access}"
  region     = "${var.default["region"]}"
}
