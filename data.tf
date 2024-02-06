# locals that hold data from datasources
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

data "aws_availability_zones" "available" {}

# use pre-build images by AWS
data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_version}-v*"]
  }
}

data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-arm64-node-${var.eks_version}-v*"]
  }
}