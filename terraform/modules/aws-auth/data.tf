data "aws_iam_group" "admin" {
  count      = var.enabled_roles ? 1 : 0
  group_name = local.cluster_group_admin
  depends_on = [
    aws_iam_group.admin,
    aws_iam_group_membership.admin
  ]
}

data "aws_iam_group" "dev" {
  count      = var.enabled_roles ? 1 : 0
  group_name = local.cluster_group_dev
  depends_on = [
    aws_iam_group.dev,
    aws_iam_group_membership.dev
  ]
}

data "aws_iam_group" "qa" {
  count      = var.enabled_roles && var.enabled_role_qa ? 1 : 0
  group_name = local.cluster_group_qa
  depends_on = [
    aws_iam_group.qa
  ]
}

data "aws_iam_role" "cluster_admin" {
  count = var.enabled_roles ? 1 : 0
  name  = local.cluster_role_admin

  depends_on = [
    aws_iam_role.cluster_admin
  ]
}

data "aws_iam_role" "cluster_dev" {
  count = var.enabled_roles ? 1 : 0
  name  = local.cluster_role_dev

  depends_on = [
    aws_iam_role.cluster_dev
  ]
}

data "aws_iam_role" "cluster_qa" {
  count = var.enabled_roles && var.enabled_role_qa ? 1 : 0
  name  = local.cluster_role_qa

  depends_on = [
    aws_iam_role.cluster_qa
  ]
}

data "aws_iam_role" "deployer" {
  count = var.enabled_roles && var.enabled_deployer_role ? 1 : 0
  name  = local.cluster_role_deployer

  depends_on = [
    aws_iam_role.deployer
  ]
}
