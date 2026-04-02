terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.east, aws.west]
    }
  }
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
  provider                   = aws.east
  replication_group_id       = "${var.app_name}-${var.env}-redis-east"
  description                = "Redis primary (east) for ${var.app_name} ${var.env}"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.r6g.large"
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true
  subnet_group_name          = aws_elasticache_subnet_group.east.name
  security_group_ids         = [aws_security_group.east.id]
}

resource "aws_elasticache_global_replication_group" "global" {
  provider                           = aws.east
  global_replication_group_id_suffix = "${var.app_name}-${var.env}"
  primary_replication_group_id       = aws_elasticache_replication_group.east.id
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
  provider                    = aws.west
  replication_group_id        = "${var.app_name}-${var.env}-redis-west"
  description                 = "Redis secondary (west) for ${var.app_name} ${var.env}"
  global_replication_group_id = aws_elasticache_global_replication_group.global.global_replication_group_id
  num_cache_clusters          = 2
  automatic_failover_enabled  = true
  subnet_group_name           = aws_elasticache_subnet_group.west.name
  security_group_ids          = [aws_security_group.west.id]

  depends_on = [aws_elasticache_global_replication_group.global]
}
