locals {
  root_device_mappings = data.aws_ami.bottlerocket_image.block_device_mappings
  autoscaler_tags      = { "k8s.io/cluster-autoscaler/enabled" = "true", "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned" }
  tags                 = merge(var.tags, { "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned" }, local.autoscaler_tags)
  labels = merge(
    var.labels
  )
  ud_labels = join("\n", flatten(concat(["[settings.kubernetes.node-labels]"], [for k, v in local.labels : "\"${k}\" = \"${v}\""])))
}

data "aws_ssm_parameter" "bottlerocket_image_id" {
  name = "/aws/service/bottlerocket/aws-k8s-${var.cluster_version}/x86_64/latest/image_id"
}

data "aws_ami" "bottlerocket_image" {
  owners = ["amazon"]
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.bottlerocket_image_id.value]
  }

   depends_on = [var.depends_list]
}

resource "aws_launch_template" "bottlerocket_lt" {
  name_prefix            = "${var.prefix_name}-bottlerocket"
  description            = "LaunchTemplate for bottlerocket"
  update_default_version = true
  key_name               = var.key_name
  ebs_optimized          = true

  # https://github.com/bottlerocket-os/bottlerocket#default-volumes
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
  image_id = data.aws_ami.bottlerocket_image.id

  user_data = base64encode(
    templatefile("${path.module}/ud_bottlerocket.toml", {
      cluster_name             = var.eks_cluster_name
      endpoint                 = var.cluster_endpoint
      cluster_auth_base64      = var.cluster_auth_base64
      kubelet_extra_args       = ""
      bootstrap_extra_args     = ""
      additional_userdata      = var.additional_userdata
      enable_admin_container   = var.enable_admin_container
      enable_control_container = true
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

