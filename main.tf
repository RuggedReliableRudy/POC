###############################################
# Secrets Lookup
###############################################
data "aws_secretsmanager_secret" "db_secret" {
  name = "pre-prod-accumulator"
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
# KMS Key (existing external key)
###############################################
locals {
  kms_arn = "arn:aws-us-gov:kms:us-gov-west-1:018743596699:key/0a3ecfea-7596-48e4-9ea7-d91f4ed389b5"
}

###############################################
# Security Groups
###############################################
resource "aws_security_group" "db" {
  name   = "pre-prod-accumulator-db-sg"
  vpc_id = var.vpc_id
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
  name   = "pre-prod-accumulator-ecs-sg"
  vpc_id = var.vpc_id
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
  identifier              = "pre-prod-accumulator-node1"
  engine                  = "postgres"
  engine_version          = "17.6"
  instance_class          = "db.m6g.large"
  allocated_storage       = 100

  storage_encrypted       = true
  kms_key_id              = local.kms_arn

  db_name                 = local.db_creds.name
  username                = local.db_creds.user
  password                = local.db_creds.password
  port                    = 5430

  parameter_group_name    = data.aws_db_parameter_group.pgactive.name
  option_group_name       = "default:postgres-17"

  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = data.aws_db_subnet_group.rds.name

  skip_final_snapshot     = true
}

###############################################
# RDS PostgreSQL Node 2
###############################################
resource "aws_db_instance" "node2" {
  identifier              = "pre-prod-accumulator-node2"
  engine                  = "postgres"
  engine_version          = "17.6"
  instance_class          = "db.m6g.large"
  allocated_storage       = 100

  storage_encrypted       = true
  kms_key_id              = local.kms_arn

  db_name                 = local.db_creds.name
  username                = local.db_creds.user
  password                = local.db_creds.password
  port                    = 5430

  parameter_group_name    = data.aws_db_parameter_group.pgactive.name
  option_group_name       = "default:postgres-17"

  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = data.aws_db_subnet_group.rds.name

  skip_final_snapshot     = true
}

###############################################
# ECS Cluster
###############################################
resource "aws_ecs_cluster" "this" {
  name = "pre-prod-accumulator-cluster"
}

###############################################
# IAM Roles (shared with dev)
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
# ECS Task Definition (App)
###############################################
resource "aws_ecs_task_definition" "cpeload" {
  family                   = "pre-prod-accumulator-cpeload-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn      = data.aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "pre-prod-accumulator-cpeload-app"
      image     = "${var.ecr_uri}:${var.image_tag}"
      essential = true
      command   = ["java", "-jar", "CpeLoad-0.1.jar"]

      environment = [
        { name = "DB_HOST", value = aws_db_instance.node1.address },
        { name = "DB_PORT", value = "5430" },
        { name = "DB_NAME", value = local.db_creds.name },
        { name = "DB_USER", value = local.db_creds.user },
        { name = "S3_BUCKET", value = "pre-prod-accumulator-glue-job" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/pre-prod-accumulator-cpeload"
          awslogs-region        = "us-gov-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/pre-prod-accumulator-cpeload"
  retention_in_days = 14
}

###############################################
# ECS Task Definition (SQL Runner)
###############################################
resource "aws_cloudwatch_log_group" "sql_runner" {
  name              = "/ecs/pre-prod-accumulator-sql-runner"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "sql_runner" {
  family                   = "pre-prod-accumulator-sql-runner-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn      = data.aws_iam_role.sql_runner.arn

  container_definitions = jsonencode([
    {
      name      = "pre-prod-accumulator-sql-runner"
      image     = "postgres:17.6"
      essential = true

      command = [
        "sh",
        "-c",
        <<-EOF
          aws s3 cp s3://pre-prod-accumulator-glue-job/docmp_tables.sql /tmp/docmp_tables.sql && \
          PGPASSWORD=${local.db_creds.password} psql -h ${aws_db_instance.node1.address} -p 5430 -U ${local.db_creds.user} -d ${local.db_creds.name} -c 'CREATE SCHEMA IF NOT EXISTS "DOCMP";' && \
          PGPASSWORD=${local.db_creds.password} psql -h ${aws_db_instance.node1.address} -p 5430 -U ${local.db_creds.user} -d ${local.db_creds.name} -f /tmp/docmp_tables.sql
        EOF
      ]

      environment = [
        { name = "AWS_REGION", value = "us-gov-west-1" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/pre-prod-accumulator-sql-runner"
          awslogs-region        = "us-gov-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

###############################################
# ECS Service (App)
###############################################
resource "aws_ecs_service" "cpeload" {
  name            = "pre-prod-accumulator-cpeload-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.cpeload.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
}
