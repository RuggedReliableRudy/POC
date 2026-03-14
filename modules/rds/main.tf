locals {
  common_tags = var.tags
}

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

resource "aws_security_group" "rds_sg" {
  name        = "cpe-rds-sg"
  description = "RDS access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
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

resource "aws_db_instance" "node1" {
  identifier              = "dev-docmp-accumulator-db1"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = 50

  db_name                 = var.db_name
  username                = local.rds_username
  password                = local.rds_password

  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  storage_encrypted       = true
  kms_key_id              = var.kms_key_arn

  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = merge(local.common_tags, { Name = "dev-docmp-accumulator-db1" })
}

resource "aws_db_instance" "node2" {
  identifier              = "dev-docmp-accumulator-db12"
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = 50

  db_name                 = var.db_name
  username                = local.rds_username
  password                = local.rds_password

  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  storage_encrypted       = true
  kms_key_id              = var.kms_key_arn

  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = merge(local.common_tags, { Name = "dev-docmp-accumulator-db12" })
}
