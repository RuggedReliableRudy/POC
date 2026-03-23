provider "aws" {
  region = "us-gov-east-1"
}

variable "app_name" { default = "accumulator-load" }
variable "env"      { default = "dev" }

locals {
  vpc_id = "vpc-0bb67cf591eb840c2"

  private_subnet_ids = [
    "subnet-0acefeb6a9825fb5b",
    "subnet-099ac7c0bf429081f",
    "subnet-08d141bf2f954a835",
    "subnet-06dfb8065d398498c"
  ]

  security_group_ids = [
    "sg-0473a57c1f7399590",
    "sg-0d4d549ec46711a91",
    "sg-0d4a77df4ebf43fa2",
    "sg-0e2fc451c79b07905"
  ]
}

# -----------------------------
# ECR
# -----------------------------
module "ecr" {
  source   = "../modules/ecr"
  app_name = var.app_name
  env      = var.env
}

# -----------------------------
# Kafka (MSK)
# -----------------------------
module "kafka" {
  source     = "../modules/kafka"
  app_name   = var.app_name
  env        = var.env
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids
  sg_ids     = local.security_group_ids
}

# -----------------------------
# Redis (regional)
# -----------------------------
module "redis" {
  source     = "../modules/redis"
  app_name   = var.app_name
  env        = var.env
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids
  sg_ids     = local.security_group_ids
}

# -----------------------------
# ALB
# -----------------------------
module "alb" {
  source       = "../modules/alb"
  app_name     = var.app_name
  env          = var.env
  vpc_id       = local.vpc_id
  subnet_ids   = local.private_subnet_ids
  sg_ids       = local.security_group_ids
  listener_port = 80
}

# -----------------------------
# ECS (Fargate)
# -----------------------------
data "aws_secretsmanager_secret" "db" {
  name = "dev/docmp/db"
}

module "ecs" {
  source   = "../modules/ecs"
  app_name = var.app_name
  env      = var.env

  aws_region = "us-gov-east-1"
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids
  sg_ids     = local.security_group_ids

  ecr_repo_url            = module.ecr.repository_url
  db_secret_arn           = data.aws_secretsmanager_secret.db.arn
  redis_endpoint          = module.redis.endpoint
  kafka_bootstrap_servers = module.kafka.bootstrap_brokers

  alb_target_group_arn = module.alb.target_group_arn
}
