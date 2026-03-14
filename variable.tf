############################################################
# ROOT MODULE VARIABLES
############################################################

# Secrets Manager secret containing:
# { "user": "postgres", "password": "xxxx" }
variable "db_credentials_secret_name" {
  type        = string
  description = "Secrets Manager secret containing DB credentials"
  default     = "accumulator"
}

# Name of the initial database to create in RDS
variable "db_name" {
  type        = string
  description = "Database name for RDS"
  default     = "accumulator"
}
