###############################################
# Global Tags
###############################################
locals {
  common_tags = {
    Environment = "Dev"
    Repository  = "Project-Accumulator"
    ManagedBy   = "Terraform"
  }
}

###############################################
# Secrets Lookup
###############################################
data "aws_secretsmanager_secret" "db_secret" {
  name = "accumulator"
}

data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}

###############################################
# VPC (existing)
###############################################
data "aws_vpc" "this" {
  id = var.vpc_id
}

###############################################
# DB Subnet Group (existing)
###############################################
data "aws_db_subnet_group" "rds" {
  name = var.db_subnet_group_name
}

###############################################
# Parameter Group (existing)
###############################################
data "aws_db_parameter_group" "pgactive" {
  name = "accumulator-postgres17"
}

###############################################
# KMS Key for RDS Encryption
###############################################
resource "aws_kms_key" "rds" {
  description         = "Customer-managed KMS key for RDS encryption"
  enable_key_rotation = true

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnableRootPermissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws-us-gov:iam::${var.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "AllowRDSUseOfKey",
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:CreateGrant",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  tags = local.common_tags
}

###############################################
# Security Groups
###############################################
resource "aws_security_group" "db" {
  name   = "pgactive-db-sg"
  vpc_id = var.vpc_id

  tags = local.common_tags
}

resource "aws_security_group_rule" "db_bidirectional" {
  type                     = "ingress"
  from_port                = 5430
  to_port                  = 5430
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.db.id
}

resource "aws_security_group" "ecs" {
  name   = "cpeload-ecs-sg"
  vpc_id = var.vpc_id

  tags = local.common_tags
}

resource "aws_security_group_rule" "ecs_to_db" {
  type                     = "ingress"
  from_port                = 5430
  to_port                  = 5430
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ecs.id
}

###############################################
# RDS PostgreSQL Node 1
###############################################
resource "aws_db_instance" "node1" {
  identifier              = "pgactive-node1"
  engine                  = "postgres"
  engine_version          = "17.6"
  instance_class          = "db.m6g.large"
  allocated_storage       = 100

  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds.arn

  db_name                 = local.db_creds.name
  username                = local.db_creds.user
  password                = local.db_creds.password
  port                    = 5430

  parameter_group_name    = data.aws_db_parameter_group.pgactive.name
  option_group_name       = "default:postgres-17"

  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = data.aws_db_subnet_group.rds.name

  skip_final_snapshot     = true

  tags = local.common_tags
}

###############################################
# RDS PostgreSQL Node 2
###############################################
resource "aws_db_instance" "node2" {
  identifier              = "pgactive-node2"
  engine                  = "postgres"
  engine_version          = "17.6"
  instance_class          = "db.m6g.large"
  allocated_storage       = 100

  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds.arn

  db_name                 = local.db_creds.name
  username                = local.db_creds.user
  password                = local.db_creds.password
  port                    = 5430

  parameter_group_name    = data.aws_db_parameter_group.pgactive.name
  option_group_name       = "default:postgres-17"

  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = data.aws_db_subnet_group.rds.name

  skip_final_snapshot     = true

  tags = local.common_tags
}

###############################################
# ECS Cluster
###############################################
resource "aws_ecs_cluster" "this" {
  name = "cpeload-cluster"

  tags = local.common_tags
}

###############################################
# IAM Roles (existing)
###############################################
data "aws_iam_role" "ecs_task_execution" {
  name = "project-cpeload-ecs-task-execution-role"
}

data "aws_iam_role" "ecs_task" {
  name = "project-cpeload-ecs-task-role"
}

data "aws_iam_role" "sql_runner" {
  name = "project-cpeload-sql-runner-role"
}

###############################################
# CloudWatch Log Groups
###############################################
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/cpeload"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "sql_runner" {
  name              = "/ecs/sql-runner"
  retention_in_days = 14

  tags = local.common_tags
}

###############################################
# ECS Task Definitions (cannot be tagged)
###############################################
resource "aws_ecs_task_definition" "cpeload" {
  ...
}

resource "aws_ecs_task_definition" "sql_runner" {
  ...
}

###############################################
# ECS Service
###############################################
resource "aws_ecs_service" "cpeload" {
  name            = "cpeload-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.cpeload.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  tags = local.common_tags
}
