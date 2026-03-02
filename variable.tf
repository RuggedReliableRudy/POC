# -------------------------
# Networking
# -------------------------

variable "vpc_id" {
  type        = string
  description = "VPC where ECS and RDS will be deployed"
}

# ECS tasks run in private subnets
variable "ecs_subnet_ids" {
  type        = list(string)
  description = "Private subnets for ECS tasks"
}

# RDS requires private subnets (must be different AZs)
variable "db_subnet_ids" {
  type        = list(string)
  description = "Private subnets for the RDS DB subnet group"
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
