terraform {
  required_version = ">= 1.1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.73.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }
}
