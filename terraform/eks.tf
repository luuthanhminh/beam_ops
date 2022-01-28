module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v18.2.3"

  cluster_name                    = local.eks_cluster_name
  cluster_version                 = var.k8s_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.key.arn
    resources        = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  tags = merge(local.tags, {
    "karpenter.sh/discovery" = local.eks_cluster_name
  })

  eks_managed_node_groups = {
    mng_addon = {
      node_group_name = "mng-addon"
      ami_type        = "BOTTLEROCKET_x86_64"
      platform        = "bottlerocket"

      create_launch_template = false
      launch_template_name   = ""
      subnet_ids             = module.vpc.private_subnets

      min_size     = 1
      max_size     = 10
      desired_size = 2

      instance_types = ["m6i.large"]
      capacity_type  = "ON_DEMAND"
      labels = {
        dedicated = "addon"
      }
      bootstrap_extra_args = <<-EOT
      # extra args added
      [settings.kernel]
      lockdown = "integrity"

      [settings.host-containers.admin]
      enabled = true
      [settings.host-containers.control]
      enabled = true
      EOT

      tags = merge(local.tags, {
        Name = "mng-addon"
      })
    }
  }
}

