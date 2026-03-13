terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region              = "us-gov-west-1"
  allowed_account_ids = ["018743596699"]
}

locals {
  vpc_id = "vpc-0bb67cf591eb840c2"

  private_subnet_ids = [
    "subnet-for-10.247.234.224/28",
    "subnet-for-10.247.234.240/28",
    "subnet-for-10.247.232.64/27",
    "subnet-for-10.247.232.96/27"
  ]

  db_subnet_group_name = "default-vpc-0bb67cf591eb840c2-new-dev"
}

resource "random_password" "rds_init" {
  length  = 32
  special = true
}

module "rds_active_active" {
  source = "./modules/rds"

  db_identifier_1      = "cpe-db-node-1"
  db_identifier_2      = "cpe-db-node-2"
  engine_version       = "17.6"
  instance_class       = "db.m6g.large"
  db_name              = "cpe_db"
  master_username      = "cpe_user"
  master_password      = random_password.rds_init.result
  vpc_id               = local.vpc_id
  db_subnet_group_name = local.db_subnet_group_name
}

module "app_ec2" {
  source = "./modules/ec2"

  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids
  instance_name      = "cpe-app-ec2"
  instance_type      = "t3.medium"

  rds_endpoints = [
    module.rds_active_active.db_endpoint_1,
    module.rds_active_active.db_endpoint_2
  ]
}

output "rds_endpoint_1" {
  value = module.rds_active_active.db_endpoint_1
}

output "rds_endpoint_2" {
  value = module.rds_active_active.db_endpoint_2
}

output "app_ec2_private_ip" {
  value = module.app_ec2.private_ip
}
