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
# VPC
###############################################
data "aws_vpc" "this" {
  id = var.vpc_id
}

###############################################
# DB Subnet Group (existing)
###############################################
data "aws_db_subnet_group" "rds" {
  name = "default-vpc-0bbb67cf591eb840c2-new-dev"
}

###############################################
# Security Groups
###############################################
resource "aws_security_group" "db" {
  name   = "pgactive-db-sg"
  vpc_id = var.vpc_id
}

# DB <-> DB replication
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
}

# ECS -> DB
resource "aws_security_group_rule" "ecs_to_db" {
  type                     = "ingress"
  from_port                = 5430
  to_port                  = 5430
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.ecs.id
}

###############################################
# Parameter Group for Logical Replication
###############################################
resource "aws_db_parameter_group" "pgactive" {
  name        = "pgactive-params"
  family      = "postgres15"
  description = "Parameter group for pgactive active-active replication"

  parameter {
    name  = "wal_level"
    value = "logical"
  }

  parameter {
    name  = "max_replication_slots"
    value = "10"
  }

  parameter {
    name  = "max_wal_senders"
    value = "10"
  }

  parameter {
    name  = "track_commit_timestamp"
    value = "on"
  }

  parameter {
    name  = "rds.logical_replication"
    value = "1"
  }
}

###############################################
# RDS PostgreSQL Node 1
###############################################
resource "aws_db_instance" "node1" {
  identifier              = "pgactive-node1"
  engine                  = "postgres"
  engine_version          = "15.3"
  instance_class          = "db.m6g.large"
  allocated_storage       = 100
  db_name                 = local.db_creds.name
  username                = local.db_creds.user
  password                = local.db_creds.password
  port                    = 5430
  parameter_group_name    = aws_db_parameter_group.pgactive.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = data.aws_db_subnet_group.rds.name
  skip_final_snapshot     = true
}

###############################################
# RDS PostgreSQL Node 2
###############################################
resource "aws_db_instance" "node2" {
  identifier              = "pgactive-node2"
  engine                  = "postgres"
  engine_version          = "15.3"
  instance_class          = "db.m6g.large"
  allocated_storage       = 100
  db_name                 = local.db_creds.name
  username                = local.db_creds.user
  password                = local.db_creds.password
  port                    = 5430
  parameter_group_name    = aws_db_parameter_group.pgactive.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  db_subnet_group_name    = data.aws_db_subnet_group.rds.name
  skip_final_snapshot     = true
}

###############################################
# ECS Cluster
###############################################
resource "aws_ecs_cluster" "this" {
  name = "cpeload-cluster"
}

###############################################
# IAM Roles (from CloudFormation)
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
  family                   = "cpeload-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn      = data.aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "cpeload-app"
      image     = "${var.ecr_uri}:${var.image_tag}"
      essential = true
      command   = ["java", "-jar", "CpeLoad-0.1.jar"]

      environment = [
        { name = "DB_HOST", value = aws_db_instance.node1.address },
        { name = "DB_PORT", value = "5430" },
        { name = "DB_NAME", value = local.db_creds.name },
        { name = "DB_USER", value = local.db_creds.user },
        { name = "S3_BUCKET", value = "project-accumulator-glue-job" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/cpeload"
          awslogs-region        = "us-gov-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/cpeload"
  retention_in_days = 14
}

###############################################
# ECS Task Definition (SQL Runner)
###############################################
resource "aws_cloudwatch_log_group" "sql_runner" {
  name              = "/ecs/sql-runner"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "sql_runner" {
  family                   = "sql-runner-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn
  task_role_arn      = data.aws_iam_role.sql_runner.arn

  container_definitions = jsonencode([
    {
      name      = "sql-runner"
      image     = "postgres:15"
      essential = true

      command = [
        "sh",
        "-c",
        <<-EOF
          aws s3 cp s3://project-accumulator-glue-job/docmp_tables.sql /tmp/docmp_tables.sql && \
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
          awslogs-group         = "/ecs/sql-runner"
          awslogs-region        = "us-gov-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


###############################################
# One-time ECS Task to Run SQL (via null_resource)
###############################################
resource "null_resource" "run_sql" {
  depends_on = [
    aws_db_instance.node1,
    aws_db_instance.node2,
    aws_ecs_task_definition.sql_runner
  ]

  provisioner "local-exec" {
    command = <<EOT
aws ecs run-task \
  --cluster ${aws_ecs_cluster.this.name} \
  --task-definition ${aws_ecs_task_definition.sql_runner.family} \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[${join(",", var.ecs_subnet_ids)}],securityGroups=[${aws_security_group.ecs.id}],assignPublicIp=DISABLED}"
EOT
  }
}

###############################################
# ECS Service (App)
###############################################
resource "aws_ecs_service" "cpeload" {
  name            = "cpeload-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.cpeload.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_controller {
    type = "ECS"
  }

  force_new_deployment = true

  network_configuration {
    subnets          = var.ecs_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  depends_on = [
    aws_ecs_task.run_sql
  ]
}

###############################################
# Outputs
###############################################
output "node1_endpoint" {
  value = aws_db_instance.node1.address
}

output "node2_endpoint" {
  value = aws_db_instance.node2.address
}
