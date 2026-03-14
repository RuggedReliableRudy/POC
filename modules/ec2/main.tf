############################################################
# GLOBAL TAGS
############################################################
locals {
  common_tags = var.tags
}

############################################################
# SECURITY GROUP FOR EC2
############################################################

resource "aws_security_group" "ec2_sg" {
  name        = "cpe-ec2-sg"
  description = "Security group for CPE EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    description = "Allow app traffic"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_app_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "cpe-ec2-sg" }
  )
}

############################################################
# IAM INSTANCE PROFILE (existing role)
############################################################

resource "aws_iam_instance_profile" "cpe_ec2_profile" {
  name = "project-ssm-managed-instance-profile"
  role = var.iam_role_name

  tags = merge(
    local.common_tags,
    { Name = "cpe-ec2-instance-profile" }
  )
}

############################################################
# KMS KEY FOR EC2 ROOT VOLUME ENCRYPTION
############################################################

resource "aws_kms_key" "ec2_kms" {
  description         = "KMS key for EC2 root volume encryption"
  enable_key_rotation = true

  tags = merge(
    local.common_tags,
    { Name = "cpe-ec2-kms" }
  )
}

resource "aws_kms_alias" "ec2_kms_alias" {
  name          = "alias/cpe-ec2-kms"
  target_key_id = aws_kms_key.ec2_kms.key_id
}

############################################################
# EC2 INSTANCE
############################################################

resource "aws_instance" "cpe_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.cpe_ec2_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = aws_kms_key.ec2_kms.arn
  }

  tags = merge(
    local.common_tags,
    { Name = "docmp-accumulator-dev" }
  )
}
