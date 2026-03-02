output "node1_endpoint" {
  value = aws_db_instance.node1.address
}

output "node2_endpoint" {
  value = aws_db_instance.node2.address
}
