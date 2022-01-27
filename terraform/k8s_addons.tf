module "kubernetes-addons" {
  source = "./modules/kubernetes-addons"

  eks_cluster_id = module.eks.cluster_id

  #K8s Add-ons
  enable_karpenter      = true
  enable_metrics_server = true

  enable_prometheus = false
  prometheus_helm_config = {
    "namespace" = "monitoring"
  }
  enable_grafana = false
  grafana_helm_config = {
    "namespace" = "monitoring"
  }
  grafana_enabled_ingress = true

  enable_aws_load_balancer_controller = false
  enable_amazon_eks_vpc_cni           = true
  enable_amazon_eks_coredns           = true
  enable_amazon_eks_kube_proxy        = true
  enable_amazon_eks_efs_csi           = false
  efs_file_system_id                  = local.efs_id
  enable_argocd                       = true

  depends_on = [module.eks.cluster_id]
}