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
# RDS INSTANCE NODE 1
############################################################

resource "aws_db_instance" "node1" {
  identifier              = "dev-docmp-accumulator-db1"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = 50

  db_name                 = var.db_name
  username                = local.rds_username
  password                = local.rds_password

  port                    = var.db_port
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  parameter_group_name    = var.parameter_group_name

  storage_encrypted       = true
  kms_key_id              = local.kms_key_id

  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false

  tags = merge(local.common_tags, { Name = "dev-docmp-accumulator-db1" })
}

############################################################
# RDS INSTANCE NODE 2
############################################################

resource "aws_db_instance" "node2" {
  identifier              = "dev-docmp-accumulator-db2"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = 50

  db_name                 = var.db_name
  username                = local.rds_username
  password                = local.rds_password

  port                    = var.db_port
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  parameter_group_name    = var.parameter_group_name

  storage_encrypted       = true
  kms_key_id              = local.kms_key_id

  skip_final_snapshot     = true
  publicly_accessible     = false
  deletion_protection     = false

  tags = merge(local.common_tags, { Name = "dev-docmp-accumulator-db2" })
}
