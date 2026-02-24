variable "vpc_id" {
  type        = string
  default     = "vpc-0faf5f1fb582102a6"
  description = "Existing VPC ID"
}

variable "ecs_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for ECS/RDS"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "cpeload"
}

variable "container_image" {
  type        = string
  description = "ECR image URI that runs CpeLoad-0.1.jar"
}

variable "desired_count" {
  type    = number
  default = 2
}
