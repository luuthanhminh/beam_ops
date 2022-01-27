data "aws_availability_zones" "available" {}

resource "aws_security_group" "efs" {
  name        = "efs-sg"
  description = "Allos inbound efs traffic from EKS node"
  vpc_id      = var.vpc_id

  ingress {
    security_groups = [var.eks_nodes_security_group, var.eks_cluster_security_group]
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }

  egress {
    security_groups = [var.eks_nodes_security_group, var.eks_cluster_security_group]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }

  tags = var.tags
}

resource "aws_efs_file_system" "efs" {
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags             = var.tags
}

resource "aws_efs_mount_target" "efs-mt" {
  count           = 2
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(var.private_subnet_ids, count.index)
  security_groups = [aws_security_group.efs.id]
}
