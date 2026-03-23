terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# No default provider; module uses aliased east/west internally

variable "app_name" {}
variable "env" {}

variable "east_vpc_id" {}
variable "east_subnet_ids" {
  type = list(string)
}

variable "west_vpc_id" {}
variable "west_subnet_ids" {
  type = list(string)
}

module "redis_global" {
  source          = "../../modules/redis_global"
  app_name        = var.app_name
  env             = var.env
  east_vpc_id     = var.east_vpc_id
  east_subnet_ids = var.east_subnet_ids
  west_vpc_id     = var.west_vpc_id
  west_subnet_ids = var.west_subnet_ids
}

output "east_redis_endpoint" {
  value = module.redis_global.east_redis_endpoint
}

output "west_redis_endpoint" {
  value = module.redis_global.west_redis_endpoint
}
