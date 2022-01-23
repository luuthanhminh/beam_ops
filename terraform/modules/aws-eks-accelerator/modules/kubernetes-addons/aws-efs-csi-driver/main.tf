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

resource "helm_release" "aws-efs-csi-driver" {
  name                       = local.helm_config["name"]
  repository                 = local.helm_config["repository"]
  chart                      = local.helm_config["chart"]
  version                    = local.helm_config["version"]
  namespace                  = local.helm_config["namespace"]
  timeout                    = local.helm_config["timeout"]
  values                     = local.helm_config["values"]
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

  postrender {
    binary_path = local.helm_config["postrender"]
  }

  dynamic "set" {
    iterator = each_item
    for_each = local.helm_config["set"] == null ? [] : local.helm_config["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
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
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_addon.irsa_iam_role_arn
    type  = "string"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = local.helm_config["controller_service_account"]
    type  = "string"
  }

  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_addon.irsa_iam_role_arn
    type  = "string"
  }

  set {
    name  = "node.serviceAccount.name"
    value = local.helm_config["node_service_account"]
    type  = "string"
  }

  set {
    name  = "storageClasses[0].parameters.fileSystemId"
    value = var.efs_file_system_id
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
  kubernetes_service_account        = local.helm_config["controller_service_account"]
  irsa_iam_policies                 = concat([aws_iam_policy.aws_efs_csi_driver.arn])
}

resource "aws_iam_policy" "aws_efs_csi_driver" {
  description = "IAM Policy for AWS EFS CSI Driver"
  name        = "${local.helm_config["name"]}-policy"
  policy      = data.aws_iam_policy_document.aws-efs-csi-driver.json
}

