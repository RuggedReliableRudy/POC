resource "aws_msk_cluster" "this" {
  cluster_name           = "${var.app_name}-${var.env}-msk"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    client_subnets  = var.subnet_ids
    security_groups = var.sg_ids
  }
}
