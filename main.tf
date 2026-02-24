data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_subnets" "ecs" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
}

# Security group for RDS
resource "aws_security_group" "rds" {
  name        = "cpeload-rds-sg"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for ECS tasks
resource "aws_security_group" "ecs" {
  name        = "cpeload-ecs-sg"
  description = "ECS Fargate security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Allow ECS to talk to RDS
resource "aws_security_group_rule" "ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5430
  to_port                  = 5430
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs.id
}

# Active-active style: Aurora PostgreSQL cluster with two instances in different AZs
resource "aws_rds_cluster" "postgres" {
  cluster_identifier = "cpeload-pg-cluster"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "15.3"
  database_name      = var.db_name
  master_username    = var.db_username
  master_password    = var.db_password

  db_subnet_group_name = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
}

resource "aws_db_subnet_group" "rds" {
  name       = "cpeload-rds-subnets"
  subnet_ids = var.ecs_subnet_ids

  tags = {
    Name = "cpeload-rds-subnet-group"
  }
}

resource "aws_rds_cluster_instance" "postgres_instances" {
  count              = 2
  identifier         = "cpeload-pg-${count.index}"
  cluster_identifier = aws_rds_cluster.postgres.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.postgres.engine

  publicly_accessible = false
}

# ECS cluster
resource "aws_ecs_cluster" "this" {
  name = "cpeload-cluster"
}

# IAM roles for ECS
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "cpeload-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name               = "cpeload-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

# Allow task to read from S3 bucket and connect to RDS
data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws-us-gov:s3:::project-accumulator-glue-job",
      "arn:aws-us-gov:s3:::project-accumulator-glue-job/*"
    ]
  }

  statement {
    actions = [
      "rds-db:connect"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "cpeload-ecs-task-policy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attach" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# ECS Task Definition (container runs CpeLoad-0.1.jar inside the image)
locals {
  container_name = "cpeload-app"
}

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
      name      = local.container_name
      image     = var.container_image
      essential = true
      command   = ["java", "-jar", "CpeLoad-0.1.jar"]

      environment = [
        {
          name  = "DB_HOST"
          value = aws_rds_cluster.postgres.endpoint
        },
        {
          name  = "DB_PORT"
          value = "5430"
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "S3_BUCKET"
          value = "project-accumulator-glue-job"
        }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_ssm_parameter.db_password.arn
        }
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

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/cpeload/db/password"
  type  = "SecureString"
  value = var.db_password
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/cpeload"
  retention_in_days = 14
}

# ECS Service
resource "aws_ecs_service" "cpeload" {
  name            = "cpeload-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.cpeload.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.ecs_subnet_ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}
