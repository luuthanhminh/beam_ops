terraform {
  required_version = ">= 1.0.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.66.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }

  backend "s3" {
    bucket  = "beam-462068371076-eks-dev"
    key     = "beam-462068371076-dev.terraformstate"
    region  = "eu-west-2"
    profile = "beam"
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.aws-eks-accelerator.eks_cluster_id

  depends_on = [
    module.aws-eks-accelerator.eks_cluster_id
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws-eks-accelerator.eks_cluster_id
  depends_on = [
    module.aws-eks-accelerator.eks_cluster_id
  ]
}

provider "aws" {
  region                  = "eu-west-2"
  profile                 = "beam"
  shared_credentials_file = "~/.aws/credentials"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone

  kubernetes_version = var.kubernetes_version

  vpc_cidr       = var.vpc_cidr
  vpc_name       = join("-", [local.tenant, local.environment, local.zone, "vpc"])
  eks_cluster_id = join("-", [local.tenant, local.environment, local.zone, "eks"])

  terraform_version = "Terraform v1.0.1"
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v3.2.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets  = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_id}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_id}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}
#---------------------------------------------------------------
# EKS Cluster
#---------------------------------------------------------------
module "aws-eks-accelerator" {
  source = "./modules/aws-eks-accelerator"

  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS CONTROL PLANE VARIABLES
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  # Self-managed Node Group
  # Karpenter requires one node to get up and running
  managed_node_groups = {
    brkt_m6xlarge_stream = {
      node_group_name = "brkt-stream"
      # create_launch_template = true
      # ami_type               = "BOTTLEROCKET_x86_64"
      launch_template_os = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket or windows
      capacity_type      = "ON_DEMAND"
      public_ip          = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      k8s_labels = {
        Environment = local.environment
        dedicated   = "stream"
      }
      max_size       = 2
      min_size       = 1
      desired_size   = 1
      instance_types = ["c5.xlarge"]
      disk_size      = 20
      disk_type      = "gp2"
      subnet_ids     = module.aws_vpc.private_subnets # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']
      additional_tags = {
        ExtraTag = "amazonlinux"
        Name     = "${local.eks_cluster_id}-stream"
      }
      create_worker_security_group = true
    },
    brkt_m6i_app = {
      node_group_name = "brkt-app"
      # create_launch_template = true
      # ami_type               = "BOTTLEROCKET_x86_64"
      launch_template_os = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket or windows
      capacity_type      = "ON_DEMAND"
      public_ip          = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      k8s_labels = {
        Environment = local.environment
        dedicated   = "app"
      }
      max_size       = 2
      min_size       = 1
      desired_size   = 1
      instance_types = ["t3.large"]
      disk_size      = 20
      disk_type      = "gp2"
      subnet_ids     = module.aws_vpc.private_subnets # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']
      additional_tags = {
        ExtraTag = "amazonlinux"
        Name     = "${local.eks_cluster_id}-app"
      }
      create_worker_security_group = true
    },
    brkt_m6i_addon = {
      node_group_name = "brkt-addon"
      # create_launch_template = true
      launch_template_os = "amazonlinux2eks" # amazonlinux2eks  or bottlerocket or windows
      capacity_type      = "ON_DEMAND"
      public_ip          = false # Use this to enable public IP for EC2 instances; only for public subnets used in launch templates ;
      k8s_labels = {
        Environment = local.environment
        dedicated   = "addon"
      }
      max_size       = 2
      min_size       = 1
      desired_size   = 1
      instance_types = ["t3.large"]
      disk_size      = 50
      disk_type      = "gp2"
      subnet_ids     = module.aws_vpc.private_subnets # Define your private/public subnets list with comma seprated subnet_ids  = ['subnet1','subnet2','subnet3']
      additional_tags = {
        ExtraTag = "amazonlinux"
        Name     = "${local.eks_cluster_id}-addon"
      }
      create_worker_security_group = true
    }
  }
}

module "kubernetes-addons" {
  source = "./modules/aws-eks-accelerator/modules/kubernetes-addons"

  eks_cluster_id = module.aws-eks-accelerator.eks_cluster_id

  #K8s Add-ons
  enable_karpenter                    = true
  enable_metrics_server               = true
  enable_prometheus                   = true
  enable_aws_load_balancer_controller = true
  enable_amazon_eks_vpc_cni           = true
  enable_amazon_eks_coredns           = true
  enable_amazon_eks_kube_proxy        = true
  enable_argocd                       = true

  depends_on = [module.aws-eks-accelerator.managed_node_groups]
}
