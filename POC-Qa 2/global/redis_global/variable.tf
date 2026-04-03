variable "app_name" { type = string }
variable "env" { type = string }
variable "east_vpc_id" { type = string }
variable "east_subnet_ids" { type = list(string) }
variable "west_vpc_id" { type = string }
variable "west_subnet_ids" { type = list(string) }

variable "east_rds_cluster_id" {
  type        = string
  description = "Identifier of the active-active Aurora cluster in us-gov-east-1"
}

variable "west_rds_cluster_id" {
  type        = string
  description = "Identifier of the active-active Aurora cluster in us-gov-west-1"
}

variable "east_rds_sg_id" {
  type        = string
  description = "Security group ID attached to the east Aurora cluster"
}

variable "west_rds_sg_id" {
  type        = string
  description = "Security group ID attached to the west Aurora cluster"
}
