#  CLUSTER LABELS
variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "462068371076"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment area, e.g. prod or preprod "
}


variable "project" {
  type        = string
  description = "Application project: Beam, ICR...."
  default     = "Beam"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "terraform_version" {
  type        = string
  default     = "Terraform"
  description = "Terraform version"
}

variable "azs" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

# VPC Config for EKS Cluster
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.10.0.0/16"
}

# EKS CONTROL PLANE
variable "create_eks" {
  type        = bool
  default     = false
  description = "Create EKS cluster"
}

variable "k8s_version" {
  type        = string
  default     = "1.21"
  description = "Desired kubernetes version. If you do not specify a value, the latest available version is used"
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the EKS private API server endpoint is enabled. Default to EKS resource and it is false"
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the EKS public API server endpoint is enabled. Default to EKS resource and it is true"
}

variable "cluster_log_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
  default     = 90
}

variable "enable_irsa" {
  type        = bool
  default     = true
  description = "Enable IAM Roles for Service Accounts"
}

variable "cluster_enabled_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "A list of the desired control plane logging to enable"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain cluster logs"
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = list(string)
  default     = []
}

variable "worker_create_security_group" {
  description = "Whether to create a security group for the workers or attach the workers to `worker_security_group_id`."
  type        = bool
  default     = true
}

# EKS WORKER NODES
variable "managed_node_groups" {
  description = "Managed node groups configuration"
  type        = any
  default     = {}
}

variable "self_managed_node_groups" {
  description = "Self-managed node groups configuration"
  type        = any
  default     = {}
}

variable "fargate_profiles" {
  description = "Fargate profile configuration"
  type        = any
  default     = {}
}

# EKS WINDOWS SUPPORT
variable "enable_windows_support" {
  description = "Enable Windows support"
  type        = bool
  default     = false
}

# CONFIGMAP AWS-AUTH
variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

#-----------Amazon Managed Prometheus-------------
variable "enable_amazon_prometheus" {
  type        = bool
  default     = false
  description = "Enable AWS Managed Prometheus service"
}

variable "amazon_prometheus_workspace_alias" {
  type        = string
  default     = null
  description = "AWS Managed Prometheus WorkSpace Name"
}

variable "enable_efs_on_eks" {
  default = true
}

variable "db_password" {
  type = string
  description = "RDS master password"
}

