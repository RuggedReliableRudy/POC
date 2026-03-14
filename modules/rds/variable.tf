############################################################
# RDS MODULE VARIABLES
############################################################

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version for the RDS instances"
}

variable "instance_class" {
  type        = string
  description = "Instance class for the RDS PostgreSQL instances"
}

variable "db_name" {
  type        = string
  description = "Initial database name to create"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS instances will be deployed"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Existing DB subnet group name"
}

############################################################
# SECRETS MANAGER CREDENTIALS
############################################################

variable "db_credentials_secret_name" {
  type        = string
  description = "Name of Secrets Manager secret containing JSON { user, password }"
}

############################################################
# EXISTING KMS KEY
############################################################

variable "kms_key_arn" {
  type        = string
  description = "Existing KMS key ARN for RDS encryption"
}

############################################################
# TAGS
############################################################

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to all RDS resources"
}
