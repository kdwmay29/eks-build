locals {
  cluster_name = "kimdw-ekstest-cluster"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "kimdw-eks-vpc"
  cidr = "10.249.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets  = ["10.249.0.0/24", "10.249.1.0/24"]
  private_subnets = ["10.249.2.0/24", "10.249.3.0/24"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}