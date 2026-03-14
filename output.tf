############################################################
# ROOT MODULE OUTPUTS
############################################################

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 private IP address"
  value       = module.ec2.private_ip
}

output "rds_endpoint_node1" {
  description = "Primary RDS instance endpoint"
  value       = module.rds.node1_endpoint
}

output "rds_endpoint_node2" {
  description = "Secondary RDS instance endpoint"
  value       = module.rds.node2_endpoint
}

output "rds_db_name" {
  description = "Database name"
  value       = module.rds.db_name
}
