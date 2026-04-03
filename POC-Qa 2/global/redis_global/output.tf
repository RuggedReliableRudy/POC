output "east_memorydb_endpoint" {
  description = "MemoryDB cluster endpoint in us-gov-east-1"
  value       = module.redis_global.east_memorydb_endpoint
}

output "west_memorydb_endpoint" {
  description = "MemoryDB cluster endpoint in us-gov-west-1"
  value       = module.redis_global.west_memorydb_endpoint
}

output "east_rds_writer_endpoint" {
  description = "Active-Active Aurora writer endpoint in us-gov-east-1"
  value       = module.redis_global.east_rds_writer_endpoint
}

output "west_rds_writer_endpoint" {
  description = "Active-Active Aurora writer endpoint in us-gov-west-1"
  value       = module.redis_global.west_rds_writer_endpoint
}

output "east_rds_reader_endpoint" {
  description = "Aurora reader endpoint in us-gov-east-1"
  value       = module.redis_global.east_rds_reader_endpoint
}

output "west_rds_reader_endpoint" {
  description = "Aurora reader endpoint in us-gov-west-1"
  value       = module.redis_global.west_rds_reader_endpoint
}

output "east_memorydb_sg_id" {
  description = "Security group ID of east MemoryDB cluster"
  value       = module.redis_global.east_memorydb_sg_id
}

output "west_memorydb_sg_id" {
  description = "Security group ID of west MemoryDB cluster"
  value       = module.redis_global.west_memorydb_sg_id
}
