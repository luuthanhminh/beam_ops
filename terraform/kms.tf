resource "aws_kms_key" "key" {
  description             = local.name
  deletion_window_in_days = 10
  tags                    = local.tags
}
