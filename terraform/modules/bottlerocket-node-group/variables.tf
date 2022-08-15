variable "cluster_version" {
  default = "1.21"
}

variable "eks_cluster_name" {
  default = "eks-cluster"
}

variable "cluster_endpoint" {
}

variable "cluster_auth_base64" {
}

variable "bottlerocket_ami_id" {
  default = ""
}


variable "key_name" {
  default = ""
}

variable "root_volume_size" {
  default = 30
}

variable "ebs_volume_size" {
  default = 30
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "prefix_name" {
  default = ""
}

variable "node_group_name" {
  default = "bottlerocket"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "capacity_type" {
  default = "ON_DEMAND"
}

variable "desired_size" {
  default = 0
}

variable "min_size" {
  default = 0
}

variable "max_size" {
  default = 0
}

variable "labels" {
  type    = map(any)
  default = {}
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "associate_public_ip_address" {
  default = false
}

variable "additional_userdata" {
  default = ""
}

variable "enable_admin_container" {
  default = false
}


variable "enabled_configmap_windows" {
  default = false
}

variable "depends_list" {
  default = []
}
