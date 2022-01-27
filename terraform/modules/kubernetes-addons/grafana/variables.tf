variable "helm_config" {
  type    = any
  default = {}
}

variable "eks_cluster_id" {
  type        = string
  description = "EKS Cluster Id"
}

variable "enabled_ingress" {
  default = false
}

variable "ingress_domain" {
  default = "monitoring.beam.to"
}

variable "ingress_annotations" {
  type    = map(any)
  default = {}
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}
