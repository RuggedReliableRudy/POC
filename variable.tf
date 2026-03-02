# -------------------------
# Networking
# -------------------------

variable "vpc_id" {
  type        = string
  description = "Existing VPC where ECS and RDS will be deployed"
}

# These are no longer provided by tfvars.
# They are populated inside main.tf using Terraform-created subnets.
variable "ecs_subnet_ids" {
  type        = list(string)
  description = "Private subnets for ECS tasks (populated from Terraform-created subnets)"
}

variable "db_subnet_ids" {
  type        = list(string)
  description = "Private subnets for the RDS DB subnet group (populated from Terraform-created subnets)"
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
