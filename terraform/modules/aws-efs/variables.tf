variable "vpc_id" {
  type        = string
  description = "Subnet for efs mount point"
}

variable "private_subnet_ids" {
  description = "List of private subnets Ids for the worker nodes"
  type        = list(string)
}

variable "eks_nodes_security_group" {
  type        = string
  description = "Security group is applied for EKS nodes"
}


variable "eks_cluster_security_group" {
  type        = string
  description = "Security group is applied for EKS cluster"
}


variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the object."
}
