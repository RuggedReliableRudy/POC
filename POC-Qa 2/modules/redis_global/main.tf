terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.east, aws.west]
    }
  }
}

###############################################################################
# EAST region – MemoryDB for Redis (multi-AZ, TLS-enforced)
###############################################################################

resource "aws_security_group" "memorydb_east" {
  provider    = aws.east
  name        = "${var.app_name}-${var.env}-memorydb-east-sg"
  description = "MemoryDB for Redis - east region"
  vpc_id      = var.east_vpc_id

  ingress {
    description = "Redis TLS inbound from VPC"
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

  tags = {
    Name        = "${var.app_name}-${var.env}-memorydb-east-sg"
    Environment = var.env
  }
}

resource "aws_memorydb_subnet_group" "east" {
  provider   = aws.east
  name       = "${var.app_name}-${var.env}-memorydb-east"
  subnet_ids = var.east_subnet_ids

  tags = {
    Name        = "${var.app_name}-${var.env}-memorydb-east"
    Environment = var.env
  }
}

resource "aws_memorydb_cluster" "east" {
  provider                 = aws.east
  name                     = "${var.app_name}-${var.env}-memdb-east"
  engine_version           = "7.0"
  node_type                = "db.r6g.large"
  num_shards               = 1
  num_replicas_per_shard   = 1 # one primary + one replica per shard = multi-AZ
  tls_enabled              = true
  snapshot_retention_limit = 7
  subnet_group_name        = aws_memorydb_subnet_group.east.id
  security_group_ids       = [aws_security_group.memorydb_east.id]

  tags = {
    Name        = "${var.app_name}-${var.env}-memdb-east"
    Environment = var.env
  }
}

###############################################################################
# WEST region – MemoryDB for Redis (multi-AZ, TLS-enforced)
###############################################################################

resource "aws_security_group" "memorydb_west" {
  provider    = aws.west
  name        = "${var.app_name}-${var.env}-memorydb-west-sg"
  description = "MemoryDB for Redis - west region"
  vpc_id      = var.west_vpc_id

  ingress {
    description = "Redis TLS inbound from VPC"
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

  tags = {
    Name        = "${var.app_name}-${var.env}-memorydb-west-sg"
    Environment = var.env
  }
}

resource "aws_memorydb_subnet_group" "west" {
  provider   = aws.west
  name       = "${var.app_name}-${var.env}-memorydb-west"
  subnet_ids = var.west_subnet_ids

  tags = {
    Name        = "${var.app_name}-${var.env}-memorydb-west"
    Environment = var.env
  }
}

resource "aws_memorydb_cluster" "west" {
  provider                 = aws.west
  name                     = "${var.app_name}-${var.env}-memdb-west"
  engine_version           = "7.0"
  node_type                = "db.r6g.large"
  num_shards               = 1
  num_replicas_per_shard   = 1
  tls_enabled              = true
  snapshot_retention_limit = 7
  subnet_group_name        = aws_memorydb_subnet_group.west.id
  security_group_ids       = [aws_security_group.memorydb_west.id]

  tags = {
    Name        = "${var.app_name}-${var.env}-memdb-west"
    Environment = var.env
  }
}

###############################################################################
# Active-Active RDS – data sources (clusters already created)
###############################################################################

data "aws_rds_cluster" "east" {
  provider           = aws.east
  cluster_identifier = var.east_rds_cluster_id
}

data "aws_rds_cluster" "west" {
  provider           = aws.west
  cluster_identifier = var.west_rds_cluster_id
}

###############################################################################
# Allow MemoryDB security groups to reach their regional RDS cluster
# The application (ECS) connects to both MemoryDB and RDS; these rules ensure
# the MemoryDB node subnets can also reach the RDS writer on port 5432.
###############################################################################

resource "aws_vpc_security_group_ingress_rule" "rds_from_memorydb_east" {
  provider                     = aws.east
  security_group_id            = var.east_rds_sg_id
  referenced_security_group_id = aws_security_group.memorydb_east.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow MemoryDB east SG to reach east RDS"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_memorydb_west" {
  provider                     = aws.west
  security_group_id            = var.west_rds_sg_id
  referenced_security_group_id = aws_security_group.memorydb_west.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow MemoryDB west SG to reach west RDS"
}
