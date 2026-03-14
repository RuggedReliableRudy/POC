variable "private_subnet_id" {
  type        = string
  description = "Private subnet where EC2 instance will be deployed"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group association"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  type        = string
  default     = "ami-04e976f26321f1ec5"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "allowed_app_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "app_port" {
  type        = number
  default     = 8080
}

variable "instance_profile_name" {
  type        = string
  description = "Existing IAM instance profile name"
}

variable "kms_key_arn" {
  type        = string
  description = "Existing KMS key ARN for EC2 root volume encryption"
}

variable "tags" {
  type        = map(string)
  default     = {}
}
