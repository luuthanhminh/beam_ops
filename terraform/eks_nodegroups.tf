# module "eks_ng_addon" {
#   source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
#   version = "18.2.3"

#   name            = "mng-addon-linux"
#   cluster_name    = module.eks.cluster_id
#   cluster_version = local.k8s_version

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   min_size     = 1
#   max_size     = 10
#   desired_size = 1

#   instance_types = ["t3.large"]
#   capacity_type  = "ON_DEMAND"

#   labels = {
#     dedicated = "addon"
#   }

#   tags = merge(local.tags, {
#     Name = "mng-addon-linux"
#   })
#   depends_on = [module.eks.cluster_id]
# }

