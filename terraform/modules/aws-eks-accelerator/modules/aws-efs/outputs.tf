output "efs_id" {
  value       = aws_efs_file_system.efs.id
  description = "The ID that identifies the file system."
}
