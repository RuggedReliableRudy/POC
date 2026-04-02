provider "aws" {
  alias  = "east"
  region = "us-gov-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-gov-west-1"
}

resource "aws_elasticache_subnet_group" "east" {
  provider   = aws.east
  name       = "${var.app_name}-${var.env}-redis-east-subnets"
  subnet_ids = var.east_subnet_ids
}

resource "aws_security_group" "east" {
  provider = aws.east
  name     = "${var.app_name}-${var.env}-redis-east-sg"
  vpc_id   = var.east_vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_replication_group" "east" {
  provider                       = aws.east
  replication_group_id           = "${var.app_name}-${var.env}-redis-east"
  replication_group_description  = "Redis east"
  engine                         = "redis"
  engine_version                 = "7.1"
  node_type                      = "cache.t4g.small"
  num_cache_clusters             = 2
  automatic_failover_enabled     = true
  subnet_group_name              = aws_elasticache_subnet_group.east.name
  security_group_ids             = [aws_security_group.east.id]
}

resource "aws_elasticache_subnet_group" "west" {
  provider   = aws.west
  name       = "${var.app_name}-${var.env}-redis-west-subnets"
  subnet_ids = var.west_subnet_ids
}

resource "aws_security_group" "west" {
  provider = aws.west
  name     = "${var.app_name}-${var.env}-redis-west-sg"
  vpc_id   = var.west_vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_replication_group" "west" {
  provider                       = aws.west
  replication_group_id           = "${var.app_name}-${var.env}-redis-west"
  replication_group_description  = "Redis west"
  engine                         = "redis"
  engine_version                 = "7.1"
  node_type                      = "cache.t4g.small"
  num_cache_clusters             = 2
  automatic_failover_enabled     = true
  subnet_group_name              = aws_elasticache_subnet_group.west.name
  security_group_ids             = [aws_security_group.west.id]
}

resource "aws_elasticache_global_replication_group" "global" {
  provider = aws.east

  global_replication_group_id_suffix = "${var.app_name}-${var.env}-redis-global"
  primary_replication_group_id       = aws_elasticache_replication_group.east.id
  secondary_replication_group_id     = aws_elasticache_replication_group.west.id
}
