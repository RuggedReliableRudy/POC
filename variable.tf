variable "vpc_id" {
  type        = string
  description = "Existing VPC where ECS and RDS will be deployed"
}

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
