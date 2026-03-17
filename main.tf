terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-gov-west-1"
}

locals {
  common_tags = {
    Environment = "QA"
    Repository  = "Project-Accumulator"
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# IMPORT DB USER + PASSWORD FROM EXISTING SECRET
# ============================================================
data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "qa/docmp/db"
}

locals {
  db_username = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string).username
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string).password
}

# ============================================================
# EXISTING RESOURCES (REFERENCED ONLY)
# ============================================================

# Existing parameter group
data "aws_db_parameter_group" "pg17" {
  name = "accumulator-postgres17"
}

# Existing security group
data "aws_security_group" "rds_sg" {
  id = "sg-06946642633980853"
}

# Existing subnets
data "aws_subnet" "subnet_a" {
  id = "subnet-05d9adf0cdf01bebf"
}

data "aws_subnet" "subnet_b" {
  id = "subnet-0514c01e9c759511f"
}

# Existing KMS key
data "aws_kms_key" "kms" {
  key_id = "arn:aws-us-gov:kms:us-gov-west-1:018743596699:key/76639fe4-775e-474c-9fd3-afa872268b5c"
}

# ============================================================
# SUBNET GROUP (REQUIRED BY RDS, BUT REFERENCES EXISTING SUBNETS)
# ============================================================
resource "aws_db_subnet_group" "pg_subnets" {
  name       = "accumulator-pg-subnets"
  subnet_ids = [
    data.aws_subnet.subnet_a.id,
    data.aws_subnet.subnet_b.id
  ]

  tags = local.common_tags
}

# ============================================================
# NODE 1 — PostgreSQL 17.6
# ============================================================
resource "aws_db_instance" "node1" {
  identifier              = "docmp-vfmp-qa-db-node1"
  engine                  = "postgres"
  engine_version          = "17.6"
  instance_class          = "db.m6g.large"
  allocated_storage       = 100
  max_allocated_storage   = 500
  db_name                 = "docmp-vfmp-qa-db"
  username                = local.db_username
  password                = local.db_password
  port                    = 5430

  vpc_security_group_ids  = [data.aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.pg_subnets.name
  parameter_group_name    = data.aws_db_parameter_group.pg17.name

  storage_encrypted       = true
  kms_key_id              = data.aws_kms_key.kms.arn

  skip_final_snapshot     = true

  tags = merge(local.common_tags, {
    Name = "docmp-vfmp-qa-db-node1"
  })
}

# ============================================================
# NODE 2 — PostgreSQL 17.6
# ============================================================
resource "aws_db_instance" "node2" {
  identifier              = "docmp-vfmp-qa-db-node2"
  engine                  = "postgres"
  engine_version          = "17.6"
  instance_class          = "db.m6g.large"
  allocated_storage       = 100
  max_allocated_storage   = 500
  db_name                 = "docmp-vfmp-qa-db"
  username                = local.db_username
  password                = local.db_password
  port                    = 5430

  vpc_security_group_ids  = [data.aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.pg_subnets.name
  parameter_group_name    = data.aws_db_parameter_group.pg17.name

  storage_encrypted       = true
  kms_key_id              = data.aws_kms_key.kms.arn

  skip_final_snapshot     = true

  tags = merge(local.common_tags, {
    Name = "docmp-vfmp-qa-db-node2"
  })
}

# ============================================================
# EXPORT ENDPOINTS BACK TO SECRETS MANAGER
# ============================================================
resource "aws_secretsmanager_secret_version" "update_db_secret" {
  secret_id = "qa/docmp/db"

  secret_string = jsonencode({
    username       = local.db_username
    password       = local.db_password
    db_endpoint_1  = aws_db_instance.node1.address
    db_endpoint_2  = aws_db_instance.node2.address
  })
}
