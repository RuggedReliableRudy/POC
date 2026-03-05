###############################################
# RDS Outputs
###############################################
output "preprod_rds_node1_endpoint" {
  description = "RDS Node 1 endpoint for pre-prod"
  value       = aws_db_instance.node1.address
}

output "preprod_rds_node2_endpoint" {
  description = "RDS Node 2 endpoint for pre-prod"
  value       = aws_db_instance.node2.address
}

output "preprod_rds_port" {
  description = "RDS port for pre-prod"
  value       = aws_db_instance.node1.port
}

output "preprod_rds_db_name" {
  description = "Database name for pre-prod"
  value       = nonsensitive(local.db_creds.name)
}

output "preprod_rds_username" {
  description = "Database username for pre-prod"
  value       = nonsensitive(local.db_creds.user)
}

###############################################
# ECS Outputs
###############################################
output "preprod_ecs_cluster_id" {
  description = "ECS Cluster ID for pre-prod"
  value       = aws_ecs_cluster.this.id
}

output "preprod_ecs_cluster_name" {
  description = "ECS Cluster name for pre-prod"
  value       = aws_ecs_cluster.this.name
}

output "preprod_ecs_service_name" {
  description = "ECS Service name for pre-prod"
  value       = aws_ecs_service.cpeload.name
}

output "preprod_ecs_task_definition_arn" {
  description = "ECS Task Definition ARN for pre-prod"
  value       = aws_ecs_task_definition.cpeload.arn
}

###############################################
# Security Groups
###############################################
output "preprod_db_security_group_id" {
  description = "DB Security Group ID for pre-prod"
  value       = aws_security_group.db.id
}

output "preprod_ecs_security_group_id" {
  description = "ECS Security Group ID for pre-prod"
  value       = aws_security_group.ecs.id
}

###############################################
# IAM Role Outputs
###############################################
output "preprod_ecs_task_execution_role_arn" {
  description = "ECS Task Execution Role ARN for pre-prod"
  value       = data.aws_iam_role.ecs_task_execution.arn
}

output "preprod_ecs_task_role_arn" {
  description = "ECS Task Role ARN for pre-prod"
  value       = data.aws_iam_role.ecs_task.arn
}

output "preprod_sql_runner_role_arn" {
  description = "SQL Runner Role ARN for pre-prod"
  value       = data.aws_iam_role.sql_runner.arn
}

###############################################
# KMS Key Output
###############################################
output "preprod_kms_key_arn" {
  description = "KMS Key ARN used for RDS encryption in pre-prod"
  value       = local.kms_arn
}

###############################################
# Logging Outputs
###############################################
output "preprod_ecs_log_group" {
  description = "CloudWatch Log Group for ECS app"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "preprod_sql_runner_log_group" {
  description = "CloudWatch Log Group for SQL Runner"
  value       = aws_cloudwatch_log_group.sql_runner.name
}
