/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: MIT-0
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#-----------------AWS Managed EKS Add-ons----------------------


module "aws_ebs_csi_driver" {
  count          = var.enable_amazon_eks_aws_ebs_csi_driver ? 1 : 0
  source         = "./aws-ebs-csi-driver"
  add_on_config  = var.amazon_eks_aws_ebs_csi_driver_config
  eks_cluster_id = var.eks_cluster_id
  common_tags    = var.tags
}


module "argocd" {
  count               = var.enable_argocd ? 1 : 0
  source              = "./argocd"
  helm_config         = var.argocd_helm_config
  argocd_applications = var.argocd_applications
  eks_cluster_id      = var.eks_cluster_id
  add_on_config       = { for k, v in local.argocd_add_on_config : k => v if v != null }
  node_selector       = var.node_selector
}


module "aws_node_termination_handler" {
  count  = var.enable_aws_node_termination_handler && length(var.auto_scaling_group_names) > 0 ? 1 : 0
  source = "./aws-node-termination-handler"

  eks_cluster_id          = var.eks_cluster_id
  helm_config             = var.aws_node_termination_handler_helm_config
  autoscaling_group_names = var.auto_scaling_group_names
  node_selector           = var.node_selector
}


module "cluster_autoscaler" {
  count             = var.enable_cluster_autoscaler ? 1 : 0
  source            = "./cluster-autoscaler"
  helm_config       = var.cluster_autoscaler_helm_config
  eks_cluster_id    = var.eks_cluster_id
  tags              = var.tags
  manage_via_gitops = var.argocd_manage_add_ons
  node_selector     = var.node_selector
}

module "aws_efs_csi" {
  count              = var.enable_amazon_eks_efs_csi ? 1 : 0
  source             = "./aws-efs-csi-driver"
  helm_config        = var.amazon_eks_efs_csi_helm_config
  efs_file_system_id = var.efs_file_system_id
  eks_cluster_id     = var.eks_cluster_id
  node_selector      = var.node_selector
}

module "metrics_server" {
  count             = var.enable_metrics_server ? 1 : 0
  source            = "./metrics-server"
  helm_config       = var.metrics_server_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  node_selector     = var.node_selector
}

module "prometheus" {
  count          = var.enable_prometheus ? 1 : 0
  source         = "./prometheus"
  eks_cluster_id = var.eks_cluster_id
  helm_config    = var.prometheus_helm_config
  #AWS Managed Prometheus Workspace
  enable_amazon_prometheus             = var.enable_amazon_prometheus
  amazon_prometheus_workspace_endpoint = var.amazon_prometheus_workspace_endpoint
  manage_via_gitops                    = var.argocd_manage_add_ons
  tags                                 = var.tags
  node_selector                        = var.node_selector
}

module "grafana" {
  count               = var.enable_grafana ? 1 : 0
  source              = "./grafana"
  eks_cluster_id      = var.eks_cluster_id
  helm_config         = var.grafana_helm_config
  manage_via_gitops   = var.argocd_manage_add_ons
  node_selector       = var.node_selector
  enabled_ingress     = var.grafana_enabled_ingress
  ingress_annotations = var.grafana_ingress_annotations
  ingress_domain      = var.grafana_ingress_domain
}

module "vpa" {
  count             = var.enable_vpa ? 1 : 0
  source            = "./vpa"
  helm_config       = var.vpa_helm_config
  manage_via_gitops = var.argocd_manage_add_ons
  node_selector     = var.node_selector
}