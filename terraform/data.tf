data "aws_iam_policy_document" "aws-efs" {
  source_json = file("${path.module}/policies/efs_policy.json")
}

data "aws_ssm_parameter" "linux_ami_id" {
  name = "/aws/service/eks/optimized-ami/${var.k8s_version}/amazon-linux-2/recommended/image_id"
}

data "aws_ssm_parameter" "bottlerocket_image_id" {
  name = "/aws/service/bottlerocket/aws-k8s-${var.k8s_version}/x86_64/latest/image_id"
}


data "aws_ami" "eks_default" {
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.linux_ami_id.value]
  }

  depends_on = [
    data.aws_ssm_parameter.linux_ami_id
  ]
}

data "aws_ami" "eks_default_bottlerocket" {
  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.bottlerocket_image_id.value]
  }

  depends_on = [
    data.aws_ssm_parameter.bottlerocket_image_id
  ]
}
