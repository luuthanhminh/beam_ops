
// Node group for common application
module "eks_ng_app" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "18.2.3"

  name            = "mng-app"
  cluster_name    = module.eks.cluster_id
  cluster_version = local.k8s_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  labels = {
    dedicated = "app"
    zone-app  = "true"
  }

  tags = merge(local.tags, {
    Name = "mng-app-linux"
  })
  depends_on = [module.eks.cluster_id]
}

// Node group for media server
module "eks_ng_media" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "18.2.3"

  name            = "mng-mediasoup"
  cluster_name    = module.eks.cluster_id
  cluster_version = local.k8s_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"

  labels = {
    dedicated      = "media-server"
    zone-mediasoup = "true"
  }

  tags = merge(local.tags, {
    Name = "mng-mediasoup-linux"
  })
  depends_on = [module.eks.cluster_id]
}

// Node group for mixer
module "eks_ng_mixer" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "18.2.3"

  name            = "mng-mediasoup"
  cluster_name    = module.eks.cluster_id
  cluster_version = local.k8s_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = ["t3.large"]
  capacity_type  = "ON_DEMAND"

  labels = {
    dedicated  = "mixer-process"
    zone-mixer = "true"
  }

  tags = merge(local.tags, {
    Name = "mng-mixer-linux"
  })
  depends_on = [module.eks.cluster_id]
}