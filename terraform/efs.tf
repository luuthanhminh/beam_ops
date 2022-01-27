module "efs" {
  count  = var.create_eks && var.enable_efs_on_eks ? 1 : 0
  source = "./modules/aws-efs"

  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnets
  eks_nodes_security_group   = module.eks.node_security_group_id
  eks_cluster_security_group = module.eks.cluster_primary_security_group_id
  tags                       = local.tags

}
