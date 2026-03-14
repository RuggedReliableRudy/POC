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

  # Existing SGs you want to attach to EC2
  ec2_security_groups = [
    "sg-0096221c182d74f1f",
    "sg-0f9f0f86559aab822",
    "sg-015d512d5b4t1c52c",
    "sg-046t2639279c75792"
  ]

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
  security_group_ids    = local.ec2_security_groups

  tags = local.common_tags
}

############################################################
# RDS MODULE
############################################################

module "rds" {
  source = "./modules/rds"

  engine_version             = "15.3"
  instance_class             = "db.t3.medium"
  db_name                    = var.db_name
  vpc_id                     = local.vpc_id
  db_subnet_group_name       = local.db_subnet_group_name
  db_credentials_secret_name = var.db_credentials_secret_name

  tags = local.common_tags
}
