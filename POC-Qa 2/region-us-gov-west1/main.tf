terraform {
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

variable "app_name" { default = "accumulator-load" }
variable "env" { default = "dev" }
# variable "image_tag" { default = "latest" }

locals {
  vpc_id = "vpc-0bb67cf591eb840c2"

  private_subnet_ids = [
    "subnet-08d141bf2f954a835",
    "subnet-06dfb8065d398498c"
  ]

  # Replace with the RDS PostgreSQL instance identifier for the active-active database
  rds_instance_id = "docmp-accumulator-dev-db-1.chvljaqaz19a.us-gov-west-1.rds.amazonaws.com"
}

module "redis" {
  source     = "../modules/redis"
  app_name   = var.app_name
  env        = var.env
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids
}

# module "ecr" {
#   source   = "../modules/ecr"
#   app_name = var.app_name
#   env      = var.env
# }

# module "kafka" {
#   source     = "../modules/kafka"
#   app_name   = var.app_name
#   env        = var.env
#   vpc_id     = local.vpc_id
#   subnet_ids = local.private_subnet_ids
#   sg_ids     = local.security_group_ids
# }

# module "alb" {
#   source        = "../modules/alb"
#   app_name      = var.app_name
#   env           = var.env
#   vpc_id        = local.vpc_id
#   subnet_ids    = local.private_subnet_ids
#   sg_ids        = local.security_group_ids
#   listener_port = 80
# }

# module "pending_updates" {
#   source   = "../modules/pending_updates"
#   app_name = var.app_name
#   env      = var.env
# }

# module "api_gateway" {
#   source       = "../modules/api_gateway"
#   app_name     = var.app_name
#   env          = var.env
#   alb_dns_name = module.alb.alb_dns_name
#   stage_name   = "v1"
# }

# data "aws_secretsmanager_secret" "db" {
#   name = "dev/docmp/db"
# }

# module "ecs" {
#   source   = "../modules/ecs"
#   app_name = var.app_name
#   env      = var.env
#
#   aws_region = "us-gov-west-1"
#   vpc_id     = local.vpc_id
#   subnet_ids = local.private_subnet_ids
#   sg_ids     = local.security_group_ids
#
#   ecr_repo_url            = module.ecr.repository_url
#   db_secret_arn           = data.aws_secretsmanager_secret.db.arn
#   redis_endpoint          = module.redis.endpoint
#   kafka_bootstrap_servers = module.kafka.bootstrap_brokers
#
#   alb_target_group_arn = module.alb.target_group_arn
#   image_tag            = var.image_tag
#   pending_table_name   = module.pending_updates.table_name
#   pending_table_arn    = module.pending_updates.table_arn
# }

# Active-Active RDS PostgreSQL instance (already created) – read-only data source
data "aws_db_instance" "active_active" {
  db_instance_identifier = local.rds_instance_id
}

output "redis_endpoint" {
  description = "Multi-AZ ElastiCache Redis primary endpoint"
  value       = module.redis.endpoint
}

output "rds_endpoint" {
  description = "Active-Active RDS PostgreSQL endpoint (us-gov-west-1)"
  value       = data.aws_db_instance.active_active.endpoint
}

output "rds_port" {
  description = "Active-Active RDS PostgreSQL port"
  value       = data.aws_db_instance.active_active.port
}

# output "alb_dns_name" {
#   value = module.alb.alb_dns_name
# }
#
# output "alb_zone_id" {
#   value = module.alb.alb_zone_id
# }
#
# output "kafka_bootstrap_brokers" {
#   value = module.kafka.bootstrap_brokers
# }
#
# output "api_gateway_invoke_url" {
#   value = module.api_gateway.invoke_url
# }
#
# output "pending_updates_table_name" {
#   value = module.pending_updates.table_name
# }
#
# output "api_gateway_hostname" {
#   value = module.api_gateway.api_hostname
# }
#
# output "api_gateway_stage" {
#   value = module.api_gateway.stage_name
# }
