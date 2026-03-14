############################################################
# RDS MODULE OUTPUTS
############################################################

output "node1_endpoint" {
  description = "Endpoint for RDS instance node1"
  value       = aws_db_instance.node1.address
}

output "node2_endpoint" {
  description = "Endpoint for RDS instance node2"
  value       = aws_db_instance.node2.address
}

output "rds_security_group_id" {
  description = "Security group ID used by both RDS nodes"
  value       = aws_security_group.rds_sg.id
}

output "rds_kms_key_arn" {
  description = "KMS key ARN used for RDS encryption"
  value       = local.rds_kms_key_arn
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}
