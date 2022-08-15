data "http" "wait_for_cluster" {
  count = var.manage_aws_auth ? 1 : 0

  url            = format("%s/healthz", data.aws_eks_cluster.cluster.endpoint)
  ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  timeout        = var.wait_for_cluster_timeout
}

resource "null_resource" "update_aws_auth" {
  count = var.manage_aws_auth ? 1 : 0

  triggers = {
    alway_runs = yamlencode(local.aws_auth_data)
  }

  provisioner "local-exec" {
    command = "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl;"
  }

  provisioner "local-exec" {
    command = "chmod +x ./kubectl;"
  }

  provisioner "local-exec" {
    command     = <<EOT
cat <<EOF | ./kubectl --server=${data.aws_eks_cluster.cluster.endpoint} --insecure-skip-tls-verify=true --token=$(echo $KUBE_TOKEN | base64 --decode) apply -f -
${yamlencode(local.aws_auth_data)}
EOF
EOT
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBE_TOKEN = base64encode(data.aws_eks_cluster_auth.cluster.token)
    }
  }

  depends_on = [
    data.http.wait_for_cluster[0]
  ]
}
