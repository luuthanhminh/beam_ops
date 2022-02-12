locals {
  root_device_mappings = data.aws_ami.linux_image.block_device_mappings
  autoscaler_tags      = { "k8s.io/cluster-autoscaler/enabled" = "true", "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned" }
  tags                 = merge(var.tags, { "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" }, local.autoscaler_tags)
  labels = merge(
    var.labels
  )
  ud_labels = join("\n", flatten(concat(["[settings.kubernetes.node-labels]"], [for k, v in local.labels : "\"${k}\" = \"${v}\""])))
}

data "aws_ssm_parameter" "linux_image_id" {
  name = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/image_id"
}

data "aws_ami" "linux_image" {
  owners = ["amazon"]
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.linux_image_id.value]
  }

  depends_on = [var.depends_list]
}

resource "aws_launch_template" "linux_lt" {
  name_prefix            = "${var.prefix_name}-linux"
  description            = "LaunchTemplate for linux"
  update_default_version = true
  key_name               = var.key_name
  ebs_optimized          = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      # kms_key_id            = var.kms_key_arn
    }
  }

  block_device_mappings {
    device_name = "/dev/xvdb"

    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      # kms_key_id            = var.kms_key_arn
    }
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = var.vpc_security_group_ids
  }

  # if you want to use a custom AMI
  image_id = data.aws_ami.linux_image.id

  user_data = base64encode(
    templatefile("${path.module}/ud_amzonlinux.tpl", {
      cluster_name             = var.eks_cluster_name
      cluster_endpoint         = var.cluster_endpoint
      cluster_auth_base64      = var.cluster_auth_base64
      bootstrap_extra_args     = "--container-runtime containerd"
      pre_bootstrap_user_data  = ""
      post_bootstrap_user_data = ""
    })
  )


  # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "instance"

    tags = merge({
      Name = var.node_group_name
      },
      local.tags
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = local.tags
  }

  # Tag the LT itself
  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

