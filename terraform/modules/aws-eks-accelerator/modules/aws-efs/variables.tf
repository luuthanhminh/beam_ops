variable "vpc_id" {
  type        = string
  description = "Subnet for efs mount point"
}

variable "subnet_id" {
  type        = string
  description = "Subnet for efs mount point"
}

variable "eks_nodes_security_group" {
  type        = string
  description = "Security group is applied for EKS nodes"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the object."
}
