############################################################
# RDS MODULE OUTPUTS
############################################################

output "db_endpoint_1" {
  description = "Endpoint for RDS instance node1"
  value       = aws_db_instance.node1.address
}

output "db_endpoint_2" {
  description = "Endpoint for RDS instance node2"
  value       = aws_db_instance.node2.address
}

output "rds_sg_id" {
  description = "Security group ID used by both RDS nodes"
  value       = aws_security_group.rds_sg.id
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}
