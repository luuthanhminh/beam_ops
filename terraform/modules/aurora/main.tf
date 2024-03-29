

locals {
  port            = var.port == "" ? var.engine == "aurora-postgresql" ? "5432" : "3306" : var.port
  master_password = var.password == "" ? random_id.master_password.b64_url : var.password
}

# Random string to use as master password unless one is specified
resource "random_id" "master_password" {
  byte_length = 20
}

#Module      : DB SUBNET GROUP
#Description : Provides an RDS DB subnet group resource.
resource "aws_db_subnet_group" "default" {
  count = var.enable == true && var.enabled_subnet_group == true ? 1 : 0

  name        = var.name
  description = format("For Aurora cluster %s", var.name)
  subnet_ids  = var.subnets
  tags        = var.tags
}

#Module      : RDS AURORA CLUSTER
#Description : Terraform module which creates RDS Aurora database resources on AWS and can
#              create different type of databases. Currently it supports Postgres and MySQL.
resource "aws_rds_cluster" "default" {
  count = var.enable == true && var.enabled_rds_cluster == true && var.serverless_enabled == false ? 1 : 0

  cluster_identifier                  = var.name
  engine                              = var.engine
  engine_version                      = var.engine_version
  kms_key_id                          = var.kms_key_id
  database_name                       = var.database_name
  master_username                     = var.username
  master_password                     = local.master_password
  final_snapshot_identifier           = format("%s-%s-%s", var.final_snapshot_identifier_prefix, var.name, random_id.snapshot_identifier.hex)
  skip_final_snapshot                 = var.skip_final_snapshot
  deletion_protection                 = var.deletion_protection
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = local.port
  db_subnet_group_name                = join("", aws_db_subnet_group.default.*.name)
  vpc_security_group_ids              = var.aws_security_group
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  apply_immediately                   = var.apply_immediately
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  db_cluster_parameter_group_name     = var.engine == "aurora-postgresql" ? aws_rds_cluster_parameter_group.postgresql.*.id[0] : aws_rds_cluster_parameter_group.aurora.*.id[0]
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  dynamic "scaling_configuration" {
    for_each = length(keys(var.scaling_configuration)) == 0 ? [] : [var.scaling_configuration]

    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
      timeout_action           = lookup(scaling_configuration.value, "timeout_action", null)
    }
  }

  dynamic "s3_import" {
    for_each = var.s3_import != null ? [var.s3_import] : []
    content {
      source_engine         = var.engine
      source_engine_version = lookup(s3_import.value, "source_engine_version", null)
      bucket_name           = lookup(s3_import.value, "bucket_name", null)
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = lookup(s3_import.value, "ingestion_role", null)
    }
  }

  tags = var.tags
}

#Module      : RDS CLUSTER INSTANCE
#Description : Terraform module which creates RDS Aurora database resources on AWS and can
#              create different type of databases. Currently it supports Postgres and MySQL.
resource "aws_rds_cluster_instance" "default" {
  count = var.enable == true && var.serverless_enabled == false ? (var.replica_scale_enabled ? var.replica_scale_min : var.replica_count) : 0

  identifier                      = var.enable == true ? format("%s-%s", var.name, (count.index + 1)) : ""
  cluster_identifier              = element(aws_rds_cluster.default.*.id, count.index)
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_type
  publicly_accessible             = var.publicly_accessible
  db_subnet_group_name            = join("", aws_db_subnet_group.default.*.name)
  db_parameter_group_name         = var.enable == true && var.engine == "aurora-postgresql" ? aws_db_parameter_group.postgresql.*.id[0] : aws_db_parameter_group.aurora.*.id[0]
  preferred_maintenance_window    = var.preferred_maintenance_window
  apply_immediately               = var.apply_immediately
  monitoring_interval             = var.monitoring_interval
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  promotion_tier                  = count.index + 1
  performance_insights_enabled    = var.performance_insights_enabled
  performance_insights_kms_key_id = var.performance_insights_kms_key_id

  tags = var.tags
}

resource "random_id" "snapshot_identifier" {
  keepers = {
    id = var.name
  }
  byte_length = 4
}

resource "aws_db_parameter_group" "postgresql" {
  count = var.enable == true && var.engine == "aurora-postgresql" && var.serverless_enabled == false ? 1 : 0

  name        = var.name
  family      = var.postgresql_family
  description = format("Parameter group for %s", var.name)
  tags        = var.tags
}

resource "aws_rds_cluster_parameter_group" "postgresql" {
  count = var.enable == true && var.engine == "aurora-postgresql" && var.serverless_enabled == false ? 1 : 0

  name        = format("%s-cluster", var.name)
  family      = var.postgresql_family
  description = format("Cluster parameter group for %s", var.name)
  tags        = var.tags
}

resource "aws_db_parameter_group" "aurora" {
  count = var.enable == true && var.engine == "aurora-mysql" && var.serverless_enabled == false ? 1 : 0

  name        = var.name
  family      = var.mysql_family
  description = format("Parameter group for %s", var.name)
  tags        = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count = var.enable == true && var.engine == "aurora-mysql" && var.serverless_enabled == false ? 1 : 0

  name        = format("%s-cluster", var.name)
  family      = var.mysql_family
  description = format("Cluster parameter group for %s", var.name)
  tags        = var.tags
}

resource "aws_rds_cluster_parameter_group" "postgresql_serverless" {
  count = var.enable && var.engine == "aurora-postgresql" ? 1 : 0

  name        = format("%s-serverless-cluster", var.name)
  family      = var.postgresql_family_serverless
  description = format("Cluster parameter group for %s Postgresql Serverless", var.name)
  tags        = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora_serverless" {
  count = var.enable && var.engine == "aurora" ? 1 : 0

  name        = format("%s-serverless-cluster", var.name)
  family      = var.mysql_family_serverless
  description = format("Cluster parameter group for %s MySQL ", var.name)
  tags        = var.tags
}
