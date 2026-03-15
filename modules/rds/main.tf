############################################################
# GLOBAL TAGS
############################################################

locals {
  common_tags = var.tags
  kms_key_id  = "arn:aws-us-gov:kms:us-gov-west-1:018743596699:key/76639fe4-775e-474c-9fd3-afa872268b5c"
}

############################################################
# SECRETS MANAGER LOOKUP
############################################################

data "aws_secretsmanager_secret" "db_creds" {
  name = var.db_credentials_secret_name
}

data "aws_secretsmanager_secret_version" "db_creds_version" {
  secret_id = data.aws_secretsmanager_secret.db_creds.id
}

locals {
  db_creds     = jsondecode(data.aws_secretsmanager_secret_version.db_creds_version.secret_string)
  rds_username = local.db_creds.user
  rds_password = local.db_creds.password
}

############################################################
# SECURITY GROUP FOR RDS
############################################################

resource "aws_security_group" "rds_sg" {
  name        = "cpe-rds-sg"
  description = "RDS access from internal VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL access"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "cpe-rds-sg" })
}

############################################################
# ALLOW EC2 → RDS CONNECTION
############################################################

resource "aws_security_group_rule" "allow_ec2_to_rds" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"

  # RDS SG (this module)
  security_group_id        = aws_security_group.rds_sg.id

  # EC2 SG (passed from EC2 module)
  source_security_group_id = var.ec2_security_group_id
}

############################################################
# RDS INSTANCE NODE 1
############################################################

resource "aws_db_instance" "node1" {
  identifier              = "