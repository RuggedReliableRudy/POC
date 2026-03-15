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

  ec2_security_groups = [
    "sg-0096221c182d74f1f",
    "sg-0f9f0f86559aab822",
    "sg-015d512d5b4t1c52c",
    "sg-046t2639279c75792"
  ]

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
  security_group_ids    = local.ec2_security_groups

  tags = local.common_tags
}

############################################################
# RDS MODULE (UPDATED)
############################################################

module "rds" {
  source = "./modules/rds"

  engine_version             = "17.6"
  instance_class             = "db.t3.medium"

  db_name                    = var.db_name
  db_port                    = 5430
  db_credentials_secret_name = var.db_credentials_secret_name

  vpc_id                     = local.vpc_id
  db_subnet_group_name       = local.db_subnet_group_name

  kms_key_arn                = local.kms_key_id

   parameter_group_name       = "accumulator-postgres17"

  tags = local.common_tags
}

############################################################
# SECURITY GROUP LINK: EC2 → RDS
############################################################

resource "aws_security_group_rule" "allow_ec2_to_rds" {
  type                     = "ingress"
  from_port                = 5430
  to_port                  = 5430
  protocol                 = "tcp"
  security_group_id        = module.rds.rds_sg_id
  source_security_group_id = local.ec2_security_groups[0]
}
