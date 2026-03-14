############################################################
# RDS MODULE VARIABLES
############################################################

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
}

variable "master_username" {
  type        = string
  description = "Master username for RDS"
}

variable "master_password" {
  type        = string
  description = "Master password for RDS"
  sensitive   = true
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for RDS security group"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Subnet group name for RDS"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "Optional external KMS key ARN for RDS encryption"
}
