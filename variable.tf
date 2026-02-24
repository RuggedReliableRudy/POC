variable "vpc_id" {
  type        = string
  default     = "vpc-0faf5f1fb582102a6"
}

variable "ecs_subnet_ids" {
  type = list(string)
  default = [
    "subnet-0d8ee0c3b94df5735",
    "subnet-0d2dc9c4e190e15ae"
  ]
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
  default = "docmp-accumulator-project"
}

variable "container_image" {
  type        = string
  description = "ECR image URI for the CpeLoad application"
}

variable "desired_count" {
  type    = number
  default = 2
}
