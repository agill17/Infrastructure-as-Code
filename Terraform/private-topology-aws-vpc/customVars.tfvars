awsProfile = "default"

vpc = {
  name = "private-topolgy"
  cidr = "10.0.0.0/16"
  bastion = true
  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  tags = {
    "Type": "PrivateTopology",
    "Purpose" : "Kubeadm"
  }
}