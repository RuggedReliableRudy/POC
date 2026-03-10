###############################################
# Terraform Settings
###############################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22"
    }
  }
}

###############################################
# AWS Provider (GovCloud)
###############################################
provider "aws" {
  region = var.region
}

###############################################
# PostgreSQL Providers (Node1 & Node2)
# These depend on RDS instances created in main.tf
###############################################

provider "postgresql" {
  alias    = "node1"
  host     = aws_db_instance.node1.address
  port     = 5430
  username = local.db_creds.user
  password = local.db_creds.password
  database = local.db_creds.name
  sslmode  = "require"
}

provider "postgresql" {
  alias    = "node2"
  host     = aws_db_instance.node2.address
  port     = 5430
  username = local.db_creds.user
  password = local.db_creds.password
  database = local.db_creds.name
  sslmode  = "require"
}
