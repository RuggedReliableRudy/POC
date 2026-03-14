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
# EXISTING SUBNETS (NO PUBLIC SUBNETS CREATED)
############################################################
locals {
  private_subnet_ids = [
    "subnet-0acefeb6a9825fb5b",
    "subnet-099ac7c0bf429081f",
    "subnet-08d141bf2f954a835",
    "subnet-06dfb8065d398498c"
  ]
}

############################################################
# VPC (YOU ALREADY HAVE ONE)
############################################################
variable "vpc_id" {
  type        = string
  description = "Existing VPC ID"
}

variable "master_password" {
  type        = string
  sensitive   = true
  description = "Master password for RDS PostgreSQL"
}

############################################################
# EC2 MODULE
############################################################
module "ec2" {
  source = "./modules/ec2"

  private_subnet_id = local.private_subnet_ids[0]   # EC2 goes in first private subnet
  vpc_id            = var.vpc_id

  ami_id            = "ami-04e976f26321f1ec5"
  instance_type     = "t3.medium"
  iam_role_name     = "project-ssm-managed-instance"

  allowed_ssh_cidrs = ["10.0.0.0/8"]
  allowed_app_cidrs = ["10.0.0.0/8"]
  app_port          = 8080

  tags = local.common_tags
}

############################################################
# RDS SUBNET GROUP (REQUIRED FOR RDS)
############################################################
resource "aws_db_subnet_group" "accumulator_subnets" {
  name       = "docmp-accumulator"
  subnet_ids = local.private_subnet_ids

  tags = merge(
    local.common_tags,
    { Name = "docmp-accumulator" }
  )
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

  vpc_id               = var.vpc_id
  db_subnet_group_name = aws_db_subnet_group.accumulator_subnets.name

  kms_key_arn = null

  tags = local.common_tags
}
