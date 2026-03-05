###############################################
# RDS Outputs
###############################################
output "qa_rds_node1_endpoint" {
  value       = aws_db_instance.node1.address
  description = "QA RDS Node 1 endpoint"
}

output "qa_rds_node2_endpoint" {
  value       = aws_db_instance.node2.address
  description = "QA RDS Node 2 endpoint"
}

output "qa_rds_port" {
  value       = aws_db_instance.node1.port
  description = "QA RDS port"
}

###############################################
# ECS Outputs
###############################################
output "qa_ecs_cluster_id" {
  value       = aws_ecs_cluster.this.id
  description = "QA ECS cluster ID"
}

output "qa_ecs_service_name" {
  value       = aws_ecs_service.cpeload.name
  description = "QA ECS service name"
}

###############################################
# Security Groups
###############################################
output "qa_db_security_group_id" {
  value       = aws_security_group.db.id
  description = "QA DB security group ID"
}

output "qa_ecs_security_group_id" {
  value       = aws_security_group.ecs.id
  description = "QA ECS security group ID"
}

###############################################
# Logging
###############################################
output "qa_ecs_log_group" {
  value       = aws_cloudwatch_log_group.ecs.name
  description = "QA ECS log group"
}

output "qa_sql_runner_log_group" {
  value       = aws_cloudwatch_log_group.sql_runner.name
  description = "QA SQL runner log group"
}
