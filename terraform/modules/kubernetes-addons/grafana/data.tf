data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudwatch" {
  source_json = file("${path.module}/cloudwatch_policy.json")
}