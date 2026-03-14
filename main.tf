############################################################
# GLOBAL TAGS
############################################################
locals {
  common_tags = {
    Environment = "Dev"
    Repository  = "Project-Accumulator"
    ManagedBy   = "Terraform"
  }
}

############################################################
# NETWORK MODULE (if you already have one)
############################################################
module "network" {
  source = "./modules/network"

  # Example variables — adjust to your actual module
  vpc_cidr_block = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]

  tags = local.common_tags
}

############################################################
# EC2 MODULE
############################################################
module "ec2" {
  source = "./modules/ec2"

  private_subnet_id = module.network.private_subnet_id
  vpc_id            = module.network.vpc_id

  ami_id            = "ami-04e976f26321f1ec5"
  instance_type     = "t3.medium"
  iam_role_name     = "project-ssm-managed-instance"

  allowed_ssh_cidrs = ["10.0.0.0/8"]
  allowed_app_cidrs = ["10.0.0.0/8"]
  app_port          = 8080

  tags = local.common_tags
}

############################################################
# RDS MODULE
############################################################
module "rds" {
  source = "./modules/rds"

  engine_version       = "15.3"
  instance_class       = "db.t3.medium"
  db_name              = "accumulatordb"
  master_username      = "postgres"
  master_password      = var.master_password

  vpc_id               = module.network.vpc_id
  db_subnet_group_name = module.network.db_subnet_group_name

  # Optional external KMS key
  kms_key_arn = null

  tags = local.common_tags
}

############################################################
# OUTPUTS FOR GITHUB ACTIONS
############################################################

output "private_ip" {
  description = "EC2 private IP for Ansible deployment"
  value       = module.ec2.private_ip
}

output "db_endpoint_1" {
  description = "Primary RDS endpoint"
  value       = module.rds.db_endpoint_1
}

output "db_endpoint_2" {
  description = "Secondary RDS endpoint"
  value       = module.rds.db_endpoint_2
}
