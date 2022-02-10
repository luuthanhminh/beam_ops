resource "helm_release" "grafana" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.helm_config["name"]
  repository                 = local.helm_config["repository"]
  chart                      = local.helm_config["chart"]
  version                    = local.helm_config["version"]
  namespace                  = local.helm_config["namespace"]
  timeout                    = local.helm_config["timeout"]
  create_namespace           = local.helm_config["create_namespace"]
  lint                       = local.helm_config["lint"]
  description                = local.helm_config["description"]
  repository_key_file        = local.helm_config["repository_key_file"]
  repository_cert_file       = local.helm_config["repository_cert_file"]
  repository_ca_file         = local.helm_config["repository_ca_file"]
  repository_username        = local.helm_config["repository_username"]
  repository_password        = local.helm_config["repository_password"]
  verify                     = local.helm_config["verify"]
  keyring                    = local.helm_config["keyring"]
  disable_webhooks           = local.helm_config["disable_webhooks"]
  reuse_values               = local.helm_config["reuse_values"]
  reset_values               = local.helm_config["reset_values"]
  force_update               = local.helm_config["force_update"]
  recreate_pods              = local.helm_config["recreate_pods"]
  cleanup_on_fail            = local.helm_config["cleanup_on_fail"]
  max_history                = local.helm_config["max_history"]
  atomic                     = local.helm_config["atomic"]
  skip_crds                  = local.helm_config["skip_crds"]
  render_subchart_notes      = local.helm_config["render_subchart_notes"]
  disable_openapi_validation = local.helm_config["disable_openapi_validation"]
  wait                       = local.helm_config["wait"]
  wait_for_jobs              = local.helm_config["wait_for_jobs"]
  dependency_update          = local.helm_config["dependency_update"]
  replace                    = local.helm_config["replace"]
  values                     = local.helm_config["values"]

  postrender {
    binary_path = local.helm_config["postrender"]
  }

  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.helm_config["set_sensitive"] == null ? [] : local.helm_config["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  set {
    name  = "ingress.enabled"
    value = var.enabled_ingress
  }

  set {
    name  = "grafana\\.ini.server.domain"
    value = var.ingress_domain
  }
  set {
    name  = "ingress.hosts[0]"
    value = var.ingress_domain
  }
  dynamic "set" {
    for_each = var.ingress_annotations

    content {
      name  = "ingress.annotations.${set.key}"
      value = set.value
    }
  }
  dynamic "set" {
    for_each = var.node_selector

    content {
      name  = "nodeSelector.${set.key}"
      value = set.value
    }
  }

  set {
    name  = "serviceAccount.name"
    value = local.helm_config["service_account"]
    type  = "string"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_addon.irsa_iam_role_arn
    type  = "string"
  }

  depends_on = [module.irsa_addon]
}

module "irsa_addon" {
  source                            = "../../../modules/irsa"
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  eks_cluster_id                    = var.eks_cluster_id
  kubernetes_namespace              = local.helm_config["namespace"]
  kubernetes_service_account        = local.helm_config["service_account"]
  irsa_iam_policies                 = concat([aws_iam_policy.cloudwatch.arn])
}

resource "aws_iam_policy" "cloudwatch" {
  description = "IAM Policy for Cloudwatch"
  name_prefix = "${local.helm_config["name"]}-policy"
  policy      = data.aws_iam_policy_document.cloudwatch.json
}
