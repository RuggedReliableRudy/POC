############################################################
# EC2 MODULE VARIABLES
############################################################

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnets for EC2 deployment"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for EC2 networking"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type"
}

variable "ami_id" {
  type        = string
  default     = "ami-04e976f26321f1ec5"
  description = "AMI ID for EC2 instance"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDRs allowed SSH access"
}

variable "allowed_app_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDRs allowed to access the application"
}

variable "app_port" {
  type        = number
  default     = 8080
  description = "Application port"
}

variable "instance_profile_name" {
  type        = string
  description = "Existing IAM instance profile name"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Existing security groups to attach to EC2"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags"
}
