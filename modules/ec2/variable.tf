############################################################
# EC2 MODULE VARIABLES
############################################################

variable "private_subnet_id" {
  type        = string
  description = "Private subnet where the EC2 instance will be deployed"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID used for creating the EC2 security group"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
  default     = "ami-04e976f26321f1ec5"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDR blocks allowed to SSH into the EC2 instance"
}

variable "allowed_app_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDR blocks allowed to access the application port"
}

variable "app_port" {
  type        = number
  default     = 8080
  description = "Application port exposed by the EC2 instance"
}

variable "iam_role_name" {
  type        = string
  description = "IAM role name attached to the EC2 instance"
  default     = "project-ssm-managed-instance"
}

############################################################
# NEW — TAGS SUPPORT
############################################################

variable "tags" {
  type        = map(string)
  description = "Tags to apply to EC2 resources"
  default     = {}
}
