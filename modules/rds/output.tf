output "db_port" {
  value = var.db_port
}

output "db_name" {
  value = var.db_name
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "node1_endpoint" {
  value = aws_db_instance.node1.address
}

output "node2_endpoint" {
  value = aws_db_instance.node2.address
}
