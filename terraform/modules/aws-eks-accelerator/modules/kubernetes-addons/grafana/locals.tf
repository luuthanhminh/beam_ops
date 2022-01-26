locals {
  default_helm_config = {
    name                       = "grafana"
    chart                      = "grafana"
    repository                 = "https://grafana.github.io/helm-charts"
    version                    = "6.21.0"
    namespace                  = "grafana"
    timeout                    = "300"
    create_namespace           = false
    description                = "Grafana helm Chart deployment configuration"
    lint                       = false
    values                     = local.default_helm_values
    wait                       = true
    wait_for_jobs              = false
    verify                     = false
    set                        = []
    set_sensitive              = null
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false
    cleanup_on_fail            = false
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    dependency_update          = false
    replace                    = false
    postrender                 = ""
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    operating_system = "linux",
  })]
}
