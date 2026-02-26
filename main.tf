# -------------------------
# Secrets Lookup
# -------------------------
data "aws_secretsmanager_secret" "db_secret" {
  name = "accumulator"
}

data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}

# -------------------------
# Aurora PostgreSQL Cluster
# -------------------------

resource "aws_db_subnet_group" "rds" {
  name       = "cpeload-rds-subnets"
  subnet_ids = var.ecs_subnet_ids
}

resource "aws_rds_cluster" "postgres" {
  cluster_identifier = "cpeload-pg-cluster"
  engine             = "aurora-postgresql"
  engine_version     = "15.3"

  # Corrected fields
  database_name   = local.db_creds.name
  master_username = local.db_creds.user
  master_password = local.db_creds.password

  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  backup_retention_period = 7
}

resource "aws_rds_cluster_instance" "postgres_instances" {
  count              = 2
  identifier         = "cpeload-pg-${count.index}"
  cluster_identifier = aws_rds_cluster.postgres.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.postgres.engine
}

# -------------------------
# ECS Task Definition
# -------------------------

resource "aws_ecs_task_definition" "cpeload" {
  family                   = "cpeload-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "cpeload-app"
      image     = "${var.ecr_uri}:${var.image_tag}"
      essential = true
      command   = ["java", "-jar", "CpeLoad-0.1.jar"]

      environment = [
        { name = "DB_HOST", value = aws_rds_cluster.postgres.endpoint },
        { name = "DB_PORT", value = "5430" },
        { name = "DB_NAME", value = var.db_name },

        # Corrected field
        { name = "DB_USER", value = local.db_creds.user },

        { name = "S3_BUCKET", value = "project-accumulator-glue-job" }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:8080/actuator/health && nc -z ${aws_rds_cluster.postgres.endpoint} 5430"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

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
