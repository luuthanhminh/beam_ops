data "aws_iam_policy_document" "aws-efs-csi-driver" {
  source_json = file("${path.module}/iam_policy.json")
}

data "aws_region" "current" {}
