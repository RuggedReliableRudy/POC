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

variable "app_name" {}
variable "env" {}

# Assume regional MSK clusters already created
variable "east_bootstrap_brokers" {}
variable "west_bootstrap_brokers" {}

module "kafka_global" {
  source = "../../modules/kafka" # or dedicated kafka_global module

  app_name  = var.app_name
  env       = var.env

  # You’d use these to configure MirrorMaker 2 ECS task
  east_bootstrap_brokers = var.east_bootstrap_brokers
  west_bootstrap_brokers = var.west_bootstrap_brokers
}
