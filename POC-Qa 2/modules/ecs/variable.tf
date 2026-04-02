variable "app_name" { type = string }
variable "env" { type = string }
variable "aws_region" { type = string }

variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "sg_ids" { type = list(string) }

variable "ecr_repo_url" { type = string }
variable "db_secret_arn" { type = string }
variable "redis_endpoint" { type = string }
variable "kafka_bootstrap_servers" { type = string }
variable "pending_table_name" { type = string }
variable "pending_table_arn" { type = string }

variable "alb_target_group_arn" { type = string }
variable "image_tag" { type = string }
