output "rds_endpoint" {
  value = aws_rds_cluster.postgres.endpoint
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}
output "ecr_repo_uri" {
  value = aws_ecr_repository.cpeload.repository_url
}
