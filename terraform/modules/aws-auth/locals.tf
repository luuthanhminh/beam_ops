locals {
  prefix_name = var.project

  # user
  user_admin = "${local.prefix_name}-admin"
  user_dev   = "${local.prefix_name}-dev"

  cluster_role_admin = "${local.prefix_name}-eks-admin"
  cluster_role_dev   = "${local.prefix_name}-eks-dev"
  cluster_role_qa    = "${local.prefix_name}-eks-qa"
  #roles
  cluster_group_admin   = "${var.project}-admin"
  cluster_group_dev     = "${var.project}-dev"
  cluster_group_qa      = "${var.project}-qa"
  cluster_role_deployer = "${var.eks_cluster_name}-deployer"

  configmap_cluster_roles = concat(
    var.enabled_roles ? [
      {
        rolearn  = join("", data.aws_iam_role.cluster_admin.*.arn)
        username = "cluster-admin"
        groups = tolist([
          "system:masters",
        ])
      },
      {
        rolearn  = join("", data.aws_iam_role.cluster_dev.*.arn)
        username = "cluster-dev"
        groups   = tolist([])
      }
    ] : [],
    var.enabled_roles && var.enabled_role_qa ? [{
      rolearn  = join("", data.aws_iam_role.cluster_qa.*.arn)
      username = "cluster-qa"
      groups   = tolist([])
    }] : [],
    var.enabled_roles && var.enabled_deployer_role ? [{
      rolearn  = join("", data.aws_iam_role.deployer.*.arn)
      username = "argocd-admin"
      groups = tolist([
        "system:masters",
      ])
    }] : []
  )

  aws_auth_data = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "aws-auth"
      namespace = "kube-system"
    }
    data = {
      mapRoles = yamlencode(
        distinct(concat(
          var.configmap_roles,
          local.configmap_cluster_roles,
          var.map_roles
        ))
      )
      mapUsers    = yamlencode(var.map_users)
      mapAccounts = yamlencode(var.map_accounts)
    }
  }
}