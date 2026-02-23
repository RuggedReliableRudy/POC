variable "project_name" { type = string }
variable "vpc_id"       { type = string }
variable "private_subnets" { type = list(string) }
variable "public_subnets"  { type = list(string) }
variable "db_name"      { type = string }
variable "db_secret_arn" { type = string } # Secrets Manager JSON
variable "s3_bucket_name" { type = string }
variable "container_port" { type = number, default = 8080 }
