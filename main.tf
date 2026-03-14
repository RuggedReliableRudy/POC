############################################################
# GLOBAL LOCALS
############################################################

locals {
  vpc_id = "vpc-0f1b4f7f8e9d12345"

  private_subnet_id = "subnet-0a1b2c3d4e5f67890"

  db_subnet_group_name = "docmp-accumulator"

  kms_key_arn = "arn:aws-us-gov:kms:us-gov-west-1:018743596699:key/6df2be77-836b-4016-956f-88d15933485b"

  instance_profile_name = "project-ssm-managed-instance"

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

  private_subnet_id     = local.private_subnet_id
  vpc_id                = local.vpc_id
  instance_profile_name = local.instance_profile_name
  kms_key_arn           = local.kms_key_arn

  tags = local.common_tags
}

############################################################
# RDS MODULE
############################################################

module "rds" {
  source = "./modules/rds"

  engine_version            = "15.3"
  instance_class            = "db.t3.medium"
  db_name                   = "accumulator"
  vpc_id                    = local.vpc_id
  db_subnet_group_name      = local.db_subnet_group_name
  db_credentials_secret_name = var.db_credentials_secret_name
  kms_key_arn               = local.kms_key_arn

  tags = local.common_tags
}
