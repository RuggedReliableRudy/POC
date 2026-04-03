terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-gov-east-1"
}

locals {
  name = "${var.app_name}-${var.env}-mm2"
}

resource "aws_cloudwatch_log_group" "mm2" {
  name              = "/ecs/${local.name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "mm2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mm2_exec" {
  name               = "${local.name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.mm2_assume.json
}

resource "aws_iam_role_policy_attachment" "mm2_exec_base" {
  role       = aws_iam_role.mm2_exec.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "mm2" {
  name = "${local.name}-cluster"
}

resource "aws_ecs_task_definition" "mm2_east_to_west" {
  family                   = "${local.name}-east-to-west"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.mm2_exec.arn

  container_definitions = jsonencode([
    {
      name      = "mirrormaker2"
      image     = var.mm2_image
      essential = true

      environment = [
        { name = "SOURCE_BOOTSTRAP_SERVERS", value = var.east_bootstrap_brokers },
        { name = "TARGET_BOOTSTRAP_SERVERS", value = var.west_bootstrap_brokers },
        { name = "REPLICATION_DIRECTION", value = "east-to-west" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.mm2.name
          "awslogs-region"        = "us-gov-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_task_definition" "mm2_west_to_east" {
  family                   = "${local.name}-west-to-east"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.mm2_exec.arn

  container_definitions = jsonencode([
    {
      name      = "mirrormaker2"
      image     = var.mm2_image
      essential = true

      environment = [
        { name = "SOURCE_BOOTSTRAP_SERVERS", value = var.west_bootstrap_brokers },
        { name = "TARGET_BOOTSTRAP_SERVERS", value = var.east_bootstrap_brokers },
        { name = "REPLICATION_DIRECTION", value = "west-to-east" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.mm2.name
          "awslogs-region"        = "us-gov-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "mm2_east_to_west" {
  name            = "${local.name}-east-to-west"
  cluster         = aws_ecs_cluster.mm2.id
  task_definition = aws_ecs_task_definition.mm2_east_to_west.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }
}

resource "aws_ecs_service" "mm2_west_to_east" {
  name            = "${local.name}-west-to-east"
  cluster         = aws_ecs_cluster.mm2.id
  task_definition = aws_ecs_task_definition.mm2_west_to_east.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }
}
