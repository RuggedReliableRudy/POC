# -------------------------
# Networking
# -------------------------

variable "vpc_id" {
  type    = string
  description = "VPC where ECS and RDS will be deployed"
}

variable "ecs_subnet_ids" {
  type = list(string)
  description = "Subnets used by ECS tasks and also RDS"
}

# RDS subnet group uses the same subnets as ECS
variable "db_subnet_ids" {
  type = list(string)
  description = "Subnets for the RDS DB subnet group (same as ECS subnets)"
}

# -------------------------
# ECS Deployment
# -------------------------

variable "desired_count" {
  type    = number
  default = 2
}

variable "ecr_uri" {
  type        = string
  description = "ECR repository URI passed from GitHub Actions"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag passed from GitHub Actions"
}
