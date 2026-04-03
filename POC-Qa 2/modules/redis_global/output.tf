output "east_memorydb_endpoint" {
  description = "MemoryDB cluster endpoint address in us-gov-east-1"
  value       = aws_memorydb_cluster.east.cluster_endpoint[0].address
}

output "west_memorydb_endpoint" {
  description = "MemoryDB cluster endpoint address in us-gov-west-1"
  value       = aws_memorydb_cluster.west.cluster_endpoint[0].address
}

output "east_rds_writer_endpoint" {
  description = "Writer endpoint of the active-active Aurora cluster in us-gov-east-1"
  value       = data.aws_rds_cluster.east.endpoint
}

output "west_rds_writer_endpoint" {
  description = "Writer endpoint of the active-active Aurora cluster in us-gov-west-1"
  value       = data.aws_rds_cluster.west.endpoint
}

output "east_rds_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster in us-gov-east-1"
  value       = data.aws_rds_cluster.east.reader_endpoint
}

output "west_rds_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster in us-gov-west-1"
  value       = data.aws_rds_cluster.west.reader_endpoint
}

output "east_memorydb_sg_id" {
  description = "Security group ID of the east MemoryDB cluster"
  value       = aws_security_group.memorydb_east.id
}

output "west_memorydb_sg_id" {
  description = "Security group ID of the west MemoryDB cluster"
  value       = aws_security_group.memorydb_west.id
}
