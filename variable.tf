# -------------------------
# Networking
# -------------------------

variable "vpc_id" {
  type    = string
  default = "vpc-0faf5f1fb582102a6"
}

variable "ecs_subnet_ids" {
  type = list(string)
  default = [
    "subnet-0d8ee0c3b94df5735",
    "subnet-0d2dc9c4e190e15ae"
  ]
}

# -------------------------
# Database Configuration
# -------------------------

variable "db_name" {
  type    = string
  default = "docmp-accumulator-project"
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
