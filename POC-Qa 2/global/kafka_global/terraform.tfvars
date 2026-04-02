app_name               = "accumulator-load"
env                    = "dev"
east_bootstrap_brokers = "REPLACE_WITH_EAST_MSK_BOOTSTRAP_BROKERS"
west_bootstrap_brokers = "REPLACE_WITH_WEST_MSK_BOOTSTRAP_BROKERS"
mm2_image              = "REPLACE_WITH_ECR_URI/mirrormaker2:latest"
subnet_ids             = ["REPLACE_SUBNET_1", "REPLACE_SUBNET_2"]
security_group_ids     = ["REPLACE_WITH_SG_ID"]
