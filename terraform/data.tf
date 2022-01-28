data "aws_iam_policy_document" "aws-efs" {
  source_json = file("${path.module}/policies/efs_policy.json")
}