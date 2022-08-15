variable "eks_cluster_name" {
  default = "eks-cluster"
}

variable "project" {
  default = "testcloud"
}

variable "tags" {
  type    = map(any)
  default = {}
}


variable "create_users" {
  default = true
}

variable "enabled_roles" {
  default = true
}

variable "reuse_roles" {
  default = false
}

variable "reuse_groups" {
  default = false
}

variable "reuse_policies" {
  default = false
}

variable "enabled_role_qa" {
  default = false
}

variable "enabled_role_app" {
  default = true
}

variable "manage_aws_auth" {
  default = true
}

variable "configmap_roles" {
  description = "Nodegroup roles to add to the aws-auth configmap."
  type        = list(any)
  default     = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "depends_list" {
  default = []
}

variable "aws_auth_additional_labels" {
  type    = map(any)
  default = {}
}

variable "wait_for_cluster_timeout" {
  type    = number
  default = 300
}

variable "enabled_deployer_role" {
  default = false
}

variable "deployer_role_arn" {
  default = ""
}
