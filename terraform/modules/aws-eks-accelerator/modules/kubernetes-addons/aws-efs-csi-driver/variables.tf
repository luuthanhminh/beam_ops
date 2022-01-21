
variable "efs_file_system_id" {
  description = "EFS file system id"
  type        = string
}

variable "helm_config" {
  type        = any
  default     = {}
  description = "Helm chart config"
}
