variable "vpc_id" {
  type        = string
  description = "Existing VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of existing private subnet IDs"
}

variable "db_subnet_group_name" {
  type        = string
  description = "Existing DB subnet group name"
}

variable "ecr_uri" {
  type        = string
  description = "ECR repository URI for the application image"
}

variable "image_tag" {
  type        = string
  description = "Image tag to deploy"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Number of ECS tasks to run"
}

variable "account_id" {
  type        = string
  description = "AWS GovCloud account ID used in KMS key policy"
}
