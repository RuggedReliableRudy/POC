###############################################
# General Settings
###############################################

variable "region" {
  description = "AWS region for all resources"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID (GovCloud format)"
  type        = string
}

###############################################
# Networking
###############################################

variable "vpc_id" {
  description = "ID of the VPC where resources will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Name of the existing DB subnet group"
  type        = string
}

###############################################
# ECS Settings
###############################################

variable "desired_count" {
  description = "Desired number of ECS tasks for the cpeload service"
  type        = number
  default     = 1
}

variable "cpeload_image" {
  description = "Container image URI for the cpeload ECS task"
  type        = string
}

variable "sql_runner_image" {
  description = "Container image URI for the sql-runner ECS task"
  type        = string
}

###############################################
# RDS / Database Settings
###############################################

variable "db_instance_class" {
  description = "Instance class for RDS PostgreSQL nodes"
  type        = string
  default     = "db.m6g.large"
}

variable "db_allocated_storage" {
  description = "Allocated storage (GB) for RDS PostgreSQL nodes"
  type        = number
  default     = 100
}

###############################################
# Application Database User
###############################################

variable "app_user" {
  description = "Application-level PostgreSQL username created on both nodes"
  type        = string
  default     = "app_user"
}

variable "app_password" {
  description = "Password for the application-level PostgreSQL user"
  type        = string
  sensitive   = true
}

###############################################
# Tags
###############################################

variable "environment" {
  description = "Environment name (e.g., Dev, QA, Prod)"
  type        = string
  default     = "Dev"
}

variable "repository" {
  description = "Repository name for tagging"
  type        = string
  default     = "Project-Accumulator"
}
