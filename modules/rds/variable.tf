############################################################
# RDS MODULE VARIABLES
############################################################

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version for RDS instances"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "db_name" {
  type        = string
  description = "Initial database name to create on both RDS nodes"
}

variable "master_username" {
  type        = string
  description = "Master username for RDS"
}

variable "master_password" {
  type        = string
  sensitive   = true
  description = "Master password for RDS"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS security group will be created"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Name of the RDS subnet group (e.g., docmp-accumulator)"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "Optional external KMS key ARN for RDS encryption"
}
