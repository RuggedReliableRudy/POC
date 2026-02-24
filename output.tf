output "rds_endpoint" {
  value = aws_rds_cluster.postgres.endpoint
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}
