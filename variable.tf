############################################################
# ROOT MODULE VARIABLES
############################################################

variable "db_credentials_secret_name" {
  type        = string
  description = "Name of Secrets Manager secret containing JSON { username, password }"
  default     = "accumulator"
}
