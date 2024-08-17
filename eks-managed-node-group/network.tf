
################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  one_nat_gateway_per_az = true

  public_subnet_names = ["${local.name}-pub01", "${local.name}-pub02"]
  private_subnet_names = ["${local.name}-pri01", "${local.name}-pri02"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.name
  }

  tags = local.tags
}

resource "aws_security_group" "ecom-sg-ecrendpoint" {
  name        = "ecom-sg-ecrendpoint"
  description = "ecom-sg-ecrendpoint"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow-https-endpoint" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecom-sg-ssmendpoint.id
  to_port           = 443
  type              = "ingress"
  description       = "https"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow-https-egress" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecom-sg-endpoint.id
  to_port                  = 443
  type                     = "egress"
  description              = "https egress"
  cidr_blocks       = ["0.0.0.0/16"]
} 


resource "aws_vpc_endpoint" "ecom-endpoint-ecr" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-northeast-2.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ecom-sg-ssmendpoint.id,
  ]

  private_dns_enabled = true

  subnet_ids =module.vpc.private_subnets
}