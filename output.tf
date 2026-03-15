############################################################
# ROOT MODULE OUTPUTS
############################################################

# EC2 Outputs
output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 private IP address"
  value       = module.ec2.private_ip
}

############################################################
# RDS Outputs
############################################################

output "db_endpoint_1" {
  description = "Primary RDS instance endpoint"
  value       = module.rds.db_endpoint_1
}

output "db_endpoint_2" {
  description = "Secondary RDS instance endpoint"
  value       = module.rds.db_endpoint_2
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

output "db_port" {
  description = "Database port"
  value       = 5430
}

output "rds_endpoint_node1" {
  description = "Primary RDS instance endpoint"
  value       = module.rds.db_endpoint_1
}

output "rds_endpoint_node2" {
  description = "Secondary RDS instance endpoint"
  value       = module.rds.db_endpoint_2
}

output "rds_db_name" {
  description = "Database name"
  value       = var.db_name
}
