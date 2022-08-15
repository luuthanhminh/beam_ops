
module "eks_ng_addon" {
  source = "./modules/bottlerocket-node-group"

  cluster_version     = local.k8s_version
  eks_cluster_name    = local.eks_cluster_name
  prefix_name         = "mng-addon"
  node_group_name     = "addon"
  # worker_iam_role_arn = module.eks.worker_iam_role_arn
  cluster_endpoint    = module.eks.cluster_endpoint
  cluster_auth_base64 = module.eks.cluster_certificate_authority_data
  subnet_ids          = module.vpc.private_subnets

  min_size     = 1
  max_size     = 2
  desired_size = 1

  instance_types = ["m6i.large"]
  capacity_type  = "ON_DEMAND"
  labels = {
    dedicated = "addon"
  }
  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id]
  tags = merge(local.tags, {
    Name = "mng-addon"
  })

  depends_on = [module.eks.cluster_id]
}

module "eks_ng_app" {
  source = "./modules/bottlerocket-node-group"

  cluster_version     = local.k8s_version
  eks_cluster_name    = local.eks_cluster_name
  prefix_name         = "mng-app"
  node_group_name     = "app"
  # worker_iam_role_arn = module.eks.cluster_iam_role_arn
  cluster_endpoint    = module.eks.cluster_endpoint
  cluster_auth_base64 = module.eks.cluster_certificate_authority_data
  subnet_ids          = module.vpc.private_subnets

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"
  labels = {
    dedicated = "app"
    zone-app  = "true"
  }
  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id]
  tags = merge(local.tags, {
    Name = "mng-app"
  })

  depends_on = [module.eks.cluster_id]
}

module "eks_ng_media" {
  source = "./modules/bottlerocket-node-group"

  cluster_version     = local.k8s_version
  eks_cluster_name    = local.eks_cluster_name
  prefix_name         = "mng-media"
  node_group_name     = "media"
  # worker_iam_role_arn = module.eks.cluster_iam_role_arn
  cluster_endpoint    = module.eks.cluster_endpoint
  cluster_auth_base64 = module.eks.cluster_certificate_authority_data
  subnet_ids          = module.vpc.public_subnets
  associate_public_ip_address = true

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"
  labels = {
    dedicated      = "media-server"
    zone-mediasoup = "true"
    app_role       = "mediasoup"
  }
  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id, aws_security_group.node_mediasoup.id]
  tags = merge(local.tags, {
    Name = "mng-media"
  })

  depends_on = [module.eks.cluster_id]
}

module "eks_ng_mixer" {
  source = "./modules/bottlerocket-node-group"

  cluster_version     = local.k8s_version
  eks_cluster_name    = local.eks_cluster_name
  prefix_name         = "mng-mixer"
  node_group_name     = "mixer"
  # worker_iam_role_arn = module.eks.
  cluster_endpoint    = module.eks.cluster_endpoint
  cluster_auth_base64 = module.eks.cluster_certificate_authority_data
  subnet_ids          = module.vpc.private_subnets

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = ["c6i.xlarge"]
  capacity_type  = "ON_DEMAND"

  labels = {
    dedicated  = "mixer-process"
    zone-mixer = "true"
  }
  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id]
  tags = merge(local.tags, {
    Name = "mng-mixer"
  })

  depends_on = [module.eks.cluster_id]
}

module "eks_ng_mixer_beta" {
  source = "./modules/bottlerocket-node-group"

  cluster_version     = local.k8s_version
  eks_cluster_name    = local.eks_cluster_name
  prefix_name         = "mng-mixer-beta"
  node_group_name     = "mixer-beta"
  # worker_iam_role_arn = module.eks.cluster_iam_role_arn
  cluster_endpoint    = module.eks.cluster_endpoint
  cluster_auth_base64 = module.eks.cluster_certificate_authority_data
  subnet_ids          = module.vpc.private_subnets

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = ["c6i.2xlarge"]
  capacity_type  = "ON_DEMAND"

  labels = {
    dedicated  = "mixer-process"
    zone-mixer-beta = "true"
  }
  vpc_security_group_ids = [module.eks.cluster_primary_security_group_id]
  tags = merge(local.tags, {
    Name = "mng-mixer-beta"
  })

  depends_on = [module.eks.cluster_id]
}

// additional policies
resource "aws_iam_policy" "aws_efs" {
  description = "IAM Policy for AWS EFS"
  name        = "${local.eks_cluster_name}-efs-policy"
  policy      = data.aws_iam_policy_document.aws-efs.json
  
  depends_on = [module.eks.cluster_id]
}


resource "aws_iam_role_policy_attachment" "eks_ng_addon_additional" {

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = module.eks_ng_addon.iam_role_name

  depends_on = [module.eks_ng_addon]
}


resource "aws_iam_role_policy_attachment" "eks_ng_mixer_additional" {

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = module.eks_ng_mixer.iam_role_name

  depends_on = [module.eks_ng_mixer]
}

resource "aws_iam_role_policy_attachment" "eks_ng_mixer_beta_additional" {

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = module.eks_ng_mixer_beta.iam_role_name

  depends_on = [module.eks_ng_mixer_beta]
}

resource "aws_iam_role_policy_attachment" "eks_ng_media_additional" {

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = module.eks_ng_media.iam_role_name

  depends_on = [module.eks_ng_media]

}

resource "aws_iam_role_policy_attachment" "eks_ng_app_additional" {

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = module.eks_ng_app.iam_role_name

  depends_on = [module.eks_ng_app]

}

