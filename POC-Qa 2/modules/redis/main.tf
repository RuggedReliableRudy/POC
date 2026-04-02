resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.app_name}-${var.env}-redis-subnets"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = "${var.app_name}-${var.env}-redis"
  description                = "Redis for ${var.app_name} ${var.env}"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t4g.small"
  num_cache_clusters         = 2
  automatic_failover_enabled = true

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = var.sg_ids
}
