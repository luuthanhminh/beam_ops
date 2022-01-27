data "aws_region" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id

  depends_on = [
    module.eks.cluster_id
  ]
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id

  depends_on = [
    module.eks.cluster_id
  ]
}

provider "aws" {
  region                  = "eu-west-2"
  profile                 = "beam"
  shared_credentials_file = "~/.aws/credentials"

  # default_tags {
  #   tags = local.tags
  # }
}


provider "kubernetes" {
  config_path = "~/.kube/config"
  # host                   = data.aws_eks_cluster.cluster.endpoint
  # cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  # token = data.aws_eks_cluster_auth.cluster.token
  # exec {
  #   api_version = "client.authentication.k8s.io/v1alpha1"
  #   args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id, "--profile", "beam"]
  #   command     = "aws"
  # }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    # host                   = data.aws_eks_cluster.cluster.endpoint
    # cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    # token = data.aws_eks_cluster_auth.cluster.token
    # exec {
    #   api_version = "client.authentication.k8s.io/v1alpha1"
    #   args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id, "--profile", "beam"]
    #   command     = "aws"
    # }
  }
}

