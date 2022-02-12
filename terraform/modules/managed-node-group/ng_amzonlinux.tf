data "aws_launch_template" "linux" {
  id = join("", aws_launch_template.linux_lt.*.id)
  depends_on = [
    aws_launch_template.linux_lt
  ]
}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {

  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "worker_role" {
  name_prefix = "${var.node_group_name}-"

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_role.name
}


resource "aws_eks_node_group" "linux" {
  cluster_name           = var.eks_cluster_name
  node_group_name_prefix = var.node_group_name
  node_role_arn          = aws_iam_role.worker_role.arn
  subnet_ids             = var.subnet_ids

  instance_types       = var.instance_types
  capacity_type        = var.capacity_type
  force_update_version = true

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  labels = var.labels

  launch_template {
    name    = join("", aws_launch_template.linux_lt.*.name)
    version = join("", data.aws_launch_template.linux.*.latest_version)
  }

  update_config {
    max_unavailable = 2
  }

  lifecycle {
    ignore_changes        = [scaling_config[0].desired_size]
    create_before_destroy = true
  }

  tags = merge(
    local.tags,
    {
      "Name" = var.node_group_name
    }
  )

  depends_on = [
    aws_launch_template.linux_lt
  ]
}

output "ng_linux_id" {
  value = join("", aws_eks_node_group.linux.*.id)
}

output "iam_role_name" {
  value = aws_iam_role.worker_role.name
}
