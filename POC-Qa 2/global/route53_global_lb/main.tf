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

variable "hosted_zone_id" {}
variable "domain_name" {}

# Assume you pull ALB outputs from remote state or pass via tfvars
variable "east_alb_dns" {}
variable "east_alb_zone" {}
variable "west_alb_dns" {}
variable "west_alb_zone" {}
variable "api_record_name" {}
variable "east_api_hostname" {}
variable "west_api_hostname" {}

module "route53_global_lb" {
  source            = "../../modules/route53_global_lb"
  hosted_zone_id    = var.hosted_zone_id
  domain_name       = var.domain_name
  east_alb_dns      = var.east_alb_dns
  east_alb_zone     = var.east_alb_zone
  west_alb_dns      = var.west_alb_dns
  west_alb_zone     = var.west_alb_zone
  api_record_name   = var.api_record_name
  east_api_hostname = var.east_api_hostname
  west_api_hostname = var.west_api_hostname
}
