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
  tags   = local.common_tags
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
  tags   = local.common_tags
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
# PostgreSQL Providers (Node1 & Node2)
###############################################
provider "postgresql" {
  alias    = "node1"
  host     = aws_db_instance.node1.address
  port     = 5430
  username = local.db_creds.user
  password = local.db_creds.password
  database = local.db_creds.name
  sslmode  = "require"
}

provider "postgresql" {
  alias    = "node2"
  host     = aws_db_instance.node2.address
  port     = 5430
  username = local.db_creds.user
  password = local.db_creds.password
  database = local.db_creds.name
  sslmode  = "require"
}

###############################################
# PostgreSQL Users
###############################################
resource "postgresql_role" "app_user_node1" {
  provider = postgresql.node1
  name     = "app_user"
  login    = true
  password = local.db_creds.password
}

resource "postgresql_role" "app_user_node2" {
  provider = postgresql.node2
  name     = "app_user"
  login    = true
  password = local.db_creds.password
}

###############################################
# PostgreSQL Privileges
###############################################
resource "postgresql_grant_role" "node1_replication" {
  provider = postgresql.node1
  role     = "rds_replication"
  member   = postgresql_role.app_user_node1.name
}

resource "postgresql_grant_role" "node1_superuser" {
  provider = postgresql.node1
  role     = "rds_superuser"
  member   = postgresql_role.app_user_node1.name
}

resource "postgresql_grant_role" "node2_replication" {
  provider = postgresql.node2
  role     = "rds_replication"
  member   = postgresql_role.app_user_node2.name
}

resource "postgresql_grant_role" "node2_superuser" {
  provider = postgresql.node2
  role     = "rds_superuser"
  member   = postgresql_role.app_user_node2.name
}

###############################################
# CONNECT Privileges
###############################################
resource "postgresql_grant" "node1_connect" {
  provider    = postgresql.node1
  database    = local.db_creds.name
  role        = postgresql_role.app_user_node1.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_grant" "node2_connect" {
  provider    = postgresql.node2
  database    = local.db_creds.name
  role        = postgresql_role.app_user_node2.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

###############################################
# pgactive Extension
###############################################
resource "postgresql_extension" "pgactive_node1" {
  provider = postgresql.node1
  name     = "pgactive"
  database = local.db_creds.name
}

resource "postgresql_extension" "pgactive_node2" {
  provider = postgresql.node2
  name     = "pgactive"
  database = local.db_creds.name
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
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "sql_runner" {
  name              = "/ecs/sql-runner"
  retention_in_days = 14
  tags              = local.common_tags
}

###############################################
# ECS Task Definition – cpeload
###############################################
resource "aws_ecs_task_definition" "cpeload" {
  family                   = "cpeload"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn            = data.aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "cpeload"
      image     = var.cpeload_image
      essential = true

      cpu       = 256
      memory    = 512

      environment = [
        { name = "DB_HOST",     value = aws_db_instance.node1.address },
        { name = "DB_PORT",     value = "5430" },
        { name = "DB_NAME",     value = local.db_creds.name },
        { name = "DB_USER",     value = local.db_creds.user },
        { name = "DB_PASSWORD", value = local.db_creds.password }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "pg_isready -h ${aws_db_instance.node1.address} -p 5430 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 20
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "cpeload"
        }
      }
    }
  ])
}

###############################################
# ECS Task Definition – sql_runner
###############################################
resource "aws_ecs_task_definition" "sql_runner" {
  family                   = "sql-runner"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn            = data.aws_iam_role.sql_runner.arn

  container_definitions = jsonencode([
    {
      name      = "sql-runner"
      image     = var.sql_runner_image
      essential = true

      cpu       = 128
      memory    = 256

      environment = [
        { name = "DB_HOST",     value = aws_db_instance.node1.address },
        { name = "DB_PORT",     value = "5430" },
        { name = "DB_NAME",     value = local.db_creds.name },
        { name = "DB_USER",     value = local.db_creds.user },
        { name = "DB_PASSWORD", value = local.db_creds.password }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "pg_isready -h ${aws_db_instance.node1.address} -p 5430 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 20
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.sql_runner.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "sql-runner"
        }
      }
    }
  ])
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
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  tags = local.common_tags
}

###############################################
# Autoscaling for ECS Service
###############################################
resource "aws_appautoscaling_target" "cpeload" {
  max_capacity       = 6
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.cpeload.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpeload_cpu" {
  name               = "cpeload-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.cpeload.resource_id
  scalable_dimension = aws_appautoscaling_target.cpeload.scalable_dimension
  service_namespace  = aws_appautoscaling_target.cpeload.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
