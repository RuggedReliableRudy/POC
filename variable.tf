############################################################
# ROOT MODULE VARIABLES
############################################################

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID where EC2 and RDS will be deployed"
}

variable "db_credentials_secret_name" {
  type        = string
  description = "Name of Secrets Manager secret containing JSON { username, password }"
  default     = "accumulator"
}
