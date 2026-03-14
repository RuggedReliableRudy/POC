###############################################
# EC2 Outputs
###############################################

output "app_ec2_private_ip" {
  description = "Private IP address of the application EC2 instance"
  value       = module.app_ec2.private_ip
}


###############################################
# RDS Outputs
###############################################

output "rds_endpoint_1" {
  description = "Endpoint for RDS PostgreSQL active-active node 1"
  value       = module.rds_active_active.db_endpoint_1
}

output "rds_endpoint_2" {
  description = "Endpoint for RDS PostgreSQL active-active node 2"
  value       = module.rds_active_active.db_endpoint_2
}
