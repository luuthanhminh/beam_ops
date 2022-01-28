module "kubernetes-addons" {
  source = "./modules/kubernetes-addons"

  eks_cluster_id = module.eks.cluster_id

  #K8s Add-ons
  enable_karpenter      = true
  eks_worker_iam_role_name = module.eks.cluster_iam_role_name
  enable_metrics_server = true

  enable_prometheus = true
  prometheus_helm_config = {
    "namespace" = "monitoring"
  }
  enable_grafana = true
  grafana_helm_config = {
    "namespace" = "monitoring"
  }
  grafana_enabled_ingress = true
  grafana_ingress_annotations = {
    "kubernetes.io/ingress.class"                    = "nginx"
    "nginx.ingress.kubernetes.io/enable-access-log"  = "true"
    "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    "nginx.ingress.kubernetes.io/proxy-body-size"    = "4096m"
    "nginx.ingress.kubernetes.io/ssl-redirect"       = "false"
  }

  enable_aws_load_balancer_controller  = false
  enable_amazon_eks_vpc_cni            = false
  enable_amazon_eks_coredns            = false
  enable_amazon_eks_kube_proxy         = false
  enable_amazon_eks_efs_csi            = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  efs_file_system_id                   = local.efs_id
  enable_argocd                        = true

  node_selector = {
    "dedicated" = "addon"
  }

  tags = local.tags

  depends_on = [module.eks.cluster_id, module.efs]
}
