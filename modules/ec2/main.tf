############################################################
# GLOBAL TAGS
############################################################

locals {
  common_tags = var.tags
}

locals {
  kms_key_id = "arn:aws-us-gov:kms:us-gov-west-1:018743596699:key/76639fe4-775e-474c-9fd3-afa872268b5c"
}

############################################################
# EXISTING SECURITY GROUP (Terraform-managed)
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

  subnet_id              = var.private_subnet_ids[0]

  # ⭐ Terraform will reuse this SG because it is already in state
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = local.kms_key_id
  }

  tags = merge(local.common_tags, { Name = "docmp-accumulator-dev" })
}


