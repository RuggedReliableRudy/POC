############################################################
# GLOBAL TAGS
############################################################
locals {
  common_tags = var.tags
}

############################################################
# VARIABLES
############################################################

variable "engine_version"       { type = string }
variable "instance_class"       { type = string }
variable "db_name"              { type = string }
variable "vpc_id"               { type = string }
variable "db_subnet_group_name" { type = string }

variable "db_credentials_secret_name" {
  type        = string
  description = "Name of Secrets Manager secret containing { username, password }"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "Optional external KMS key ARN for RDS encryption"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all RDS resources"
  default     = {}
}

############################################################
# SECRETS MANAGER LOOKUP
############################################################

data "aws_secretsmanager_secret" "db_creds" {
  name = var.db_credentials_secret_name
}

data "aws_secretsmanager_secret_version" "db_creds_version" {
  secret_id = data.aws_secretsmanager_secret.db_creds.id
}

locals {
  db_creds     = jsondecode(data.aws_secretsmanager_secret_version.db_creds_version.secret_string)
  rds_username = local.db_creds.username
  rds_password = local.db_creds.password
}

############################################################
# KMS KEY FOR RDS ENCRYPTION
############################################################

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "rds_kms" {
  count               = var.kms_key_arn == null ? 1 : 0
  description         = "KMS key for encrypting RDS PostgreSQL instances"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EnableRootAccount"
        Effect   = "Allow"
        Principal = {
          AWS = "arn:aws-us-gov:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.common_tags,
    { Name = "cpe-rds-kms" }
  )
}

resource "aws_kms_alias" "rds_kms_alias" {
  count        = var.kms_key_arn == null ? 1 : 0
  name         = "alias/cpe-rds-kms"
  target_key_id = aws_kms_key.rds_kms[0].key_id
}

locals {
  rds_kms_key_arn = var.kms_key_arn != null ? var.kms_key_arn : aws_kms_key.rds_kms[0].arn
}

############################################################
# SECURITY GROUP FOR RDS
############################################################

resource "aws_security_group" "rds_sg" {
  name        = "cpe-rds-sg"
  description = "RDS access from app EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "Postgres from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "cpe-rds-sg" }
  )
}

############################################################
# RDS NODE 1
############################################################

resource "aws_db_instance" "node1" {
  identifier              = "dev-docmp-accumulator-db1"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = 50

  db_name                 = var.db_name
  username                = local.rds_username
  password                = local.rds_password

  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  storage_encrypted       = true
  kms_key_id              = local.rds_kms_key_arn

  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false

  tags = merge(
    local.common_tags,
    { Name = "dev-docmp-accumulator-db1" }
  )
}

############################################################
# RDS NODE 2
############################################################

resource "aws_db_instance" "node2" {
  identifier              = "dev-docmp-accumulator-db12"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = 50

  db_name                 = var.db_name
  username                = local.rds_username
  password                = local.rds_password

  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  storage_encrypted       = true
  kms_key_id              = local.rds_kms_key_arn

  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  deletion_protection     = false

  tags = merge(
    local.common_tags,
    { Name = "dev-docmp-accumulator-db12" }
  )
}
