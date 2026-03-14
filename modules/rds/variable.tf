variable "engine_version" { type = string }
variable "instance_class" { type = string }
variable "db_name"        { type = string }
variable "vpc_id"         { type = string }

variable "db_subnet_group_name" {
  type        = string
  description = "Existing DB subnet group name"
}

variable "db_credentials_secret_name" {
  type        = string
}

variable "kms_key_arn" {
  type        = string
  description = "Existing KMS key ARN for RDS encryption"
}

variable "tags" {
  type        = map(string)
  default     = {}
}
