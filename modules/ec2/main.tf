############################################################
# GLOBAL TAGS
############################################################

locals {
  common_tags = var.tags
}

############################################################
# KMS KEY FOR EC2 ROOT VOLUME
############################################################

resource "aws_kms_key" "ec2_kms" {
  description         = "KMS key for EC2 root volume encryption"
  enable_key_rotation = true

  tags = merge(local.common_tags, {
    Name = "ec2-kms-key"
  })
}

resource "aws_kms_alias" "ec2_kms_alias" {
  name          = "alias/ec2-kms-key"
  target_key_id = aws_kms_key.ec2_kms.key_id
}

############################################################
# SECURITY GROUP (OPTIONAL — REMOVE IF USING EXISTING SGs)
############################################################

resource "aws_security_group" "ec2_sg" {
  name        = "cpe-ec2-sg"
  description = "Security group for EC2"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    description = "Application port"
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

  tags = merge(local.common_tags, { Name = "cpe-ec2-sg" })
}

############################################################
# EC2 INSTANCE
############################################################

resource "aws_instance" "cpe_app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type

  # Use the FIRST private subnet
  subnet_id              = var.private_subnet_ids[0]

  # If using existing SGs, replace with: var.security_group_ids
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = aws_kms_key.ec2_kms.arn
  }

  tags = merge(local.common_tags, { Name = "docmp-accumulator-dev" })
}

############################################################
# OUTPUTS
############################################################

output "instance_id" {
  value = aws_instance.cpe_app.id
}

output "private_ip" {
  value = aws_instance.cpe_app.private_ip
}

output "iam_instance_profile" {
  value = var.instance_profile_name
}

output "kms_key_arn" {
  value = aws_kms_key.ec2_kms.arn
}
