variable "app_name" { type = string }
variable "env" { type = string }

variable "east_vpc_id" { type = string }
variable "east_subnet_ids" { type = list(string) }

variable "west_vpc_id" { type = string }
variable "west_subnet_ids" { type = list(string) }

# Active-Active RDS cluster identifiers (clusters must already exist)
variable "east_rds_cluster_id" {
  type        = string
  description = "Identifier of the Aurora cluster in us-gov-east-1 (active-active RDS)"
}

variable "west_rds_cluster_id" {
  type        = string
  description = "Identifier of the Aurora cluster in us-gov-west-1 (active-active RDS)"
}

# Security group IDs attached to the Aurora clusters (used to grant MemoryDB access)
variable "east_rds_sg_id" {
  type        = string
  description = "Security group ID of the east Aurora cluster"
}

variable "west_rds_sg_id" {
  type        = string
  description = "Security group ID of the west Aurora cluster"
}
