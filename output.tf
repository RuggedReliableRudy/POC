# ============================================================
# EC2 Outputs
# ============================================================

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 private IP address"
  value       = module.ec2.private_ip
}

# ============================================================
# RDS Outputs
# ============================================================

output "db_endpoint_1" {
  description = "Primary RDS instance endpoint"
  value       = module.rds.node1_endpoint
}

output "db_endpoint_2" {
  description = "Secondary RDS instance endpoint"
  value       = module.rds.node2_endpoint
}

output "db_name" {
  description = "Database name"
  value       = module.rds.db_name
}

output "db_port" {
  description = "Database port"
  value       = module.rds.db_port
}

output "rds_sg_id" {
  description = "RDS security group ID"
  value       = module.rds.rds_sg_id
}
