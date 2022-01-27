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
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = "ac01234b-00d9-40f6-ac95-e42345f78b00"
    resources        = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  tags       = local.tags

  eks_managed_node_groups = {
    node_group_name = "mng-addon"

    subnet_ids = module.vpc.private_subnets

    min_size     = 1
    max_size     = 10
    desired_size = 1

    instance_types = ["t3.large"]
    capacity_type  = "ON_DEMAND"
    labels = {
      dedicated = "addon"
    }

    tags = merge(local.tags, {
      Name = "mng-addon"
    })
  }
}

