resource "aws_iam_role" "managed_ng" {
  name                  = "${var.eks_cluster_id}-${local.managed_node_group["node_group_name"]}"
  assume_role_policy    = data.aws_iam_policy_document.managed_ng_assume_role_policy.json
  path                  = var.path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "managed_ng" {
  name = "${var.eks_cluster_id}-${local.managed_node_group["node_group_name"]}"
  role = aws_iam_role.managed_ng.name

  path = var.path
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "managed_ng" {
  for_each   = local.eks_worker_policies
  policy_arn = each.key
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_role_policy_attachment" "efs_attachment" {
  policy_arn = aws_iam_policy.aws_efs.arn
  role       = aws_iam_role.managed_ng.name
}

resource "aws_iam_policy" "aws_efs" {
  description = "IAM Policy for AWS EFS "
  policy      = data.aws_iam_policy_document.aws-efs.json
}


