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
}


provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:eu-west-2:462068371076:cluster/462068371076-dev-ops-eks"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "arn:aws:eks:eu-west-2:462068371076:cluster/462068371076-dev-ops-eks"
  }
}

