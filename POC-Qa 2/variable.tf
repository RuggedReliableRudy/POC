variable "aws_region" {
  type        = string
  description = "Primary AWS region"
  default     = "us-gov-west-1"
}

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "accumulator-load"
}

variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "ecr_uri" {
  type        = string
  description = "ECR repository URI"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}
