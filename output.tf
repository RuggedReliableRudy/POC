############################################################
# OUTPUTS FOR GITHUB ACTIONS
############################################################
output "private_ip" {
  description = "EC2 private IP for Ansible deployment"
  value       = module.ec2.private_ip
}

output "db_endpoint_1" {
  description = "Primary RDS endpoint"
  value       = module.rds.db_endpoint_1
}

output "db_endpoint_2" {
  description = "Secondary RDS endpoint"
  value       = module.rds.db_endpoint_2
}
