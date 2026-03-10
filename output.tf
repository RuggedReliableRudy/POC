###############################################
# VPC & Networking Outputs
###############################################
output "vpc_id" {
  description = "The VPC ID used for the infrastructure"
  value       = var.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnets used by ECS tasks"
  value       = var.private_subnet_ids
}

###############################################
# RDS Outputs
###############################################
output "rds_node1_endpoint" {
  description = "Primary RDS PostgreSQL node endpoint"
  value       = aws_db_instance.node1.address
}

output "rds_node2_endpoint" {
  description = "Secondary RDS PostgreSQL node endpoint"
  value       = aws_db_instance.node2.address
}

output "rds_node1_port" {
  description = "Port for RDS PostgreSQL node 1"
  value       = aws_db_instance.node1.port
}

output "rds_node2_port" {
  description = "Port for RDS PostgreSQL node 2"
  value       = aws_db_instance.node2.port
}

###############################################
# PostgreSQL User / DB Outputs
###############################################
output "app_user" {
  description = "Application-level PostgreSQL user created on both nodes"
  value       = var.app_user
}

output "database_name" {
  description = "Database name created on both RDS nodes"
  value       = local.db_creds.name
}

###############################################
# ECS Outputs
###############################################
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.cpeload.name
}

output "ecs_task_definition_cpeload" {
  description = "ARN of the cpeload ECS task definition"
  value       = aws_ecs_task_definition.cpeload.arn
}

output "ecs_task_definition_sql_runner" {
  description = "ARN of the sql-runner ECS task definition"
  value       = aws_ecs_task_definition.sql_runner.arn
}

###############################################
# ECR Image Outputs
###############################################
output "cpeload_image" {
  description = "Full ECR image URI used for the cpeload task"
  value       = var.cpeload_image
}

output "sql_runner_image" {
  description = "Full ECR image URI used for the sql-runner task"
  value       = var.sql_runner_image
}

###############################################
# Tags / Metadata
###############################################
output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

output "repository" {
  description = "Repository name used for tagging"
  value       = var.repository
}
