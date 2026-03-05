###############################################
# RDS Outputs
###############################################
output "preprod_rds_node1_endpoint" {
  description = "Pre‑prod RDS Node 1 endpoint"
  value       = aws_db_instance.node1.address
}

output "preprod_rds_node2_endpoint" {
  description = "Pre‑prod RDS Node 2 endpoint"
  value       = aws_db_instance.node2.address
}

output "preprod_rds_port" {
  description = "Pre‑prod RDS port"
  value       = aws_db_instance.node1.port
}

output "preprod_rds_db_name" {
  description = "Pre‑prod database name"
  value       = nonsensitive(local.db_creds.name)
}

output "preprod_rds_username" {
  description = "Pre‑prod database username"
  value       = nonsensitive(local.db_creds.user)
}

###############################################
# ECS Outputs
###############################################
output "preprod_ecs_cluster_id" {
  description = "Pre‑prod ECS cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "preprod_ecs_service_name" {
  description = "Pre‑prod ECS service name"
  value       = aws_ecs_service.cpeload.name
}

###############################################
# Security Groups
###############################################
output "preprod_db_security_group_id" {
  description = "Pre‑prod DB security group ID"
  value       = aws_security_group.db.id
}

output "preprod_ecs_security_group_id" {
  description = "Pre‑prod ECS security group ID"
  value       = aws_security_group.ecs.id
}

###############################################
# Logging
###############################################
output "preprod_ecs_log_group" {
  description = "Pre‑prod ECS log group"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "preprod_sql_runner_log_group" {
  description = "Pre‑prod SQL runner log group"
  value       = aws_cloudwatch_log_group.sql_runner.name
}

###############################################
# KMS Key
###############################################
output "preprod_kms_key_arn" {
  description = "KMS key ARN used for RDS encryption"
  value       = local.kms_arn
}
