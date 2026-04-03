app_name        = "accumulator-load"
env             = "dev"
east_vpc_id     = "REPLACE_WITH_EAST_VPC_ID"
east_subnet_ids = ["REPLACE_EAST_SUBNET_1", "REPLACE_EAST_SUBNET_2", "REPLACE_EAST_SUBNET_3"]
west_vpc_id     = "REPLACE_WITH_WEST_VPC_ID"
west_subnet_ids = ["REPLACE_WEST_SUBNET_1", "REPLACE_WEST_SUBNET_2", "REPLACE_WEST_SUBNET_3"]

# Active-Active RDS – fill in the cluster identifiers and their security group IDs
east_rds_cluster_id = "REPLACE_WITH_EAST_AURORA_CLUSTER_ID"
west_rds_cluster_id = "REPLACE_WITH_WEST_AURORA_CLUSTER_ID"
east_rds_sg_id      = "REPLACE_WITH_EAST_AURORA_SG_ID"
west_rds_sg_id      = "REPLACE_WITH_WEST_AURORA_SG_ID"
