############################################################
# ROOT MODULE VARIABLES
############################################################

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID where EC2 and RDS will be deployed"
}

variable "master_password" {
  type        = string
  description = "Master password for RDS PostgreSQL"
  sensitive   = true
}
