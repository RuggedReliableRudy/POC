############################################################
# EC2 MODULE VARIABLES
############################################################

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnets where EC2 instances may be deployed"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group association"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type"
}

variable "ami_id" {
  type        = string
  default     = "ami-04e976f26321f1ec5"
  description = "AMI ID for EC2 instance"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDR blocks allowed to SSH into the EC2 instance"
}

variable "allowed_app_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/8"]
  description = "CIDR blocks allowed to access the application port"
}

variable "app_port" {
  type        = number
  default     = 8080
  description = "Application port exposed on the EC2 instance"
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
  description = "Common tags applied to all EC2 resources"
}
