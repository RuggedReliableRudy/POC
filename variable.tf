############################################################
# ROOT MODULE VARIABLES
############################################################

# ============================================================
# Secrets Manager secret containing:
# { "user": "postgres", "password": "xxxx" }
# ============================================================
variable "db_credentials_secret_name" {
  type        = string
  description = "Secrets Manager secret containing DB credentials"
  default     = "accumulator"
}

# ============================================================
# Name of the initial database to create in RDS
# ============================================================
variable "db_name" {
  type        = string
  description = "Database name for RDS"
  default     = "accumulator"
}

# ============================================================
# Database port (passed to RDS module)
# ============================================================
variable "db_port" {
  type        = number
  description = "Port for PostgreSQL database"
  default     = 5430
}

# ============================================================
# KMS Key ARN for RDS encryption
# ============================================================
variable "kms_key_arn" {
  type        = string
  description = "Existing KMS key ARN for RDS encryption"
  default     = "arn:aws-us-gov:kms:us-gov-west-1:018743596699:key/76639fe4-775e-474c-9fd3-afa872268b5c"
}
