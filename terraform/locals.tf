locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone
  project     = var.project

  k8s_version       = var.k8s_version
  terraform_version = "v1.1.2"

  name = join("-", [local.tenant, local.environment, local.zone])

  vpc_cidr         = var.vpc_cidr
  public_subnets   = [for k, v in var.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in var.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]
  vpc_name         = join("-", [local.name, "vpc"])
  eks_cluster_name = join("-", [local.name, "eks"])


  efs_id = var.create_eks && var.enable_efs_on_eks ? module.efs[0].efs_id : null

  tags = {
    tenant            = local.tenant
    environment       = local.environment
    zone              = var.zone
    project           = local.project
    provision_by      = "Terraform"
    terraform_version = local.terraform_version
  }

}
