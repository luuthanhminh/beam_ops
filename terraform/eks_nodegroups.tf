


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
    app_role = "mediasoup"
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

  vpc_id                 = module.vpc.vpc_id
  vpc_security_group_ids = [aws_security_group.node_mediasoup.id]
  subnet_ids             = module.vpc.private_subnets

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

// additional policies
resource "aws_iam_policy" "aws_efs" {
  description = "IAM Policy for AWS EFS"
  name        = "${local.eks_cluster_name}-efs-policy"
  policy      = data.aws_iam_policy_document.aws-efs.json
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = each.value.iam_role_name
}


resource "aws_iam_role_policy_attachment" "eks_ng_mixer_additional" {

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = module.eks_ng_mixer.iam_role_name
}

resource "aws_iam_role_policy_attachment" "eks_ng_media_additional" {

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = module.eks_ng_media.iam_role_name

}

resource "aws_iam_role_policy_attachment" "eks_ng_app_additional" {

  policy_arn = aws_iam_policy.aws_efs.arn
  role       = module.eks_ng_app.iam_role_name

}

