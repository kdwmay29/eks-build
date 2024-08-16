module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = local.cluster_name
  cluster_version                 = "1.23"
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cloudwatch_log_group_retention_in_days = 1

  fargate_profiles = {
    coredns = {
      name                 = "coredns" 
      pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn
      selectors = [
        {
          namespace = "kube-system"
        }
      ]
    }
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
    mgmt = {
      name = "mgmt"
      selectors = [
        {
          namespace = "mgmt"
        }
      ]
    }
    service = {
      name = "service"
      selectors = [
        {
          namespace = "service"
        }
      ]
    }
  }
}