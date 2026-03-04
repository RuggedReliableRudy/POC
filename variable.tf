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
}

variable "image_tag" {
  type        = string
}

variable "desired_count" {
  type        = number
  default     = 1
}
