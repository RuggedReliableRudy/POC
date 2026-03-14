############################################################
# GLOBAL TAGS
############################################################

locals {
  common_tags = var.tags
}

############################################################
# SECURITY GROUP
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

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = var.kms_key_arn
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
