module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = local.name
  description = "PostgreSQL  security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from everywhere"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}

################################################################################
# AURORA RDS Module
################################################################################

module "postgres" {
  source      = "./modules/aurora"
  name        = "beam-dev"
  environment = local.environment
  label_order = ["name", "environment"]

  username                            = "beam_admin"
  database_name                       = "beam"
  password                            = var.db_password
  engine                              = "aurora-postgresql"
  engine_version                      = "12.7"
  db_cluster_parameter_group_name     = "aurora-postgresql12"
  postgresql_family                   = "aurora-postgresql12"
  subnets                             = module.vpc.public_subnets
  aws_security_group                  = [module.db_security_group.security_group_id]
  replica_count                       = 1
  instance_type                       = "db.r6g.large"
  apply_immediately                   = true
  skip_final_snapshot                 = true
  publicly_accessible                 = true
  iam_database_authentication_enabled = false

  tags = local.tags
}
