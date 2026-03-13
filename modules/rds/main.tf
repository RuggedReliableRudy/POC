variable "db_identifier_1" { type = string }
variable "db_identifier_2" { type = string }
variable "engine_version"  { type = string }
variable "instance_class"  { type = string }
variable "db_name"         { type = string }
variable "master_username" { type = string }
variable "master_password" { type = string }
variable "vpc_id"          { type = string }
variable "db_subnet_group_name" { type = string }

resource "aws_security_group" "rds_sg" {
  name        = "cpe-rds-sg"
  description = "RDS access from app EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "Postgres from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # tighten as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "node1" {
  identifier              = var.db_identifier_1
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = 50
  db_name                 = var.db_name
  username                = var.master_username
  password                = var.master_password
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  deletion_protection     = false
}

resource "aws_db_instance" "node2" {
  identifier              = var.db_identifier_2
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = 50
  db_name                 = var.db_name
  username                = var.master_username
  password                = var.master_password
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  deletion_protection     = false
}

output "db_endpoint_1" {
  value = aws_db_instance.node1.address
}

output "db_endpoint_2" {
  value = aws_db_instance.node2.address
}
