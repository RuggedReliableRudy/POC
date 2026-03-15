############################################################
# GLOBAL LOCALS
############################################################

locals {
  vpc_id = "vpc-0f1b4f7f8e9d12345"

  private_subnet_ids = [
    "subnet-0acefeb6a9825fb5b",
    "subnet-099ac7c0bf429081f",
    "subnet-08d141bf2f954a835",
    "subnet-06dfb8065d398498c"
  ]

  db_subnet_group_name = "docmp-accumulator"

  instance_profile_name = "project-ssm-managed-instance"

  kms_key_id = "arn:aws-us-gov:kms:us-gov-west-1:018743596699:key/76639fe4-775e-474c-9fd3-afa872268b5c"

  common_tags = {
    Environment = "Dev"
    Repository  = "Project-Accumulator"
    ManagedBy   = "Terraform"
  }
}

############################################################
# EC2 MODULE
############################################################

module "ec2" {
  source = "./modules/ec2"

  private_subnet_ids    = local.private_subnet_ids
  vpc_id                = local.vpc_id
  instance_profile_name = local.instance_profile_name

  tags = local.common_tags
}

############################################################
# RDS MODULE
############################################################

module "rds" {
  source = "./modules/rds"

  engine_version             = "17.6"
  instance_class             = "db.t3.medium"

  db_name                    = var.db_name
  db_port                    = var.db_port
  db_credentials_secret_name = var.db_credentials_secret_name

  vpc_id                     = local.vpc_id
  db_subnet_group_name       = local.db_subnet_group_name

  kms_key_arn                = local.kms_key_id

  parameter_group_name       = "accumulator-postgres17"

  ec2_security_group_id      = module.ec2.ec2_sg_id

  tags = local.common_tags
}

############################################################
# ⭐ NO SECURITY GROUP RULES IN ROOT
############################################################
