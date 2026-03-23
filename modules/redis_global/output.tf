output "east_redis_endpoint" {
  value = aws_elasticache_replication_group.east.primary_endpoint_address
}

output "west_redis_endpoint" {
  value = aws_elasticache_replication_group.west.primary_endpoint_address
}
