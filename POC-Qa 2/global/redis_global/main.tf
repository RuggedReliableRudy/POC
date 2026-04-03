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

provider "aws" {
  alias  = "east"
  region = "us-gov-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-gov-west-1"
}

module "redis_global" {
  source = "../../modules/redis_global"

  providers = {
    aws.east = aws.east
    aws.west = aws.west
  }

  app_name        = var.app_name
  env             = var.env
  east_vpc_id     = var.east_vpc_id
  east_subnet_ids = var.east_subnet_ids
  west_vpc_id     = var.west_vpc_id
  west_subnet_ids = var.west_subnet_ids

  east_rds_cluster_id = var.east_rds_cluster_id
  west_rds_cluster_id = var.west_rds_cluster_id
  east_rds_sg_id      = var.east_rds_sg_id
  west_rds_sg_id      = var.west_rds_sg_id
}
