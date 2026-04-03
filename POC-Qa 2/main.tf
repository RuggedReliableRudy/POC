# Root-level workspace for shared configuration.
#
# Deploy each workspace independently in this order:
#
#   Step 1 — East region:
#     cd region-us-gov-east1 && terraform init && terraform apply
#
#   Step 2 — West region:
#     cd region-us-gov-west1 && terraform init && terraform apply
#
#   Step 3 — Global Redis (after both regions are up):
#     cd global/redis_global && terraform init && terraform apply
#
#   Step 4 — Global Route53 LB (after both ALBs are up):
#     cd global/route53_global_lb && terraform init && terraform apply
#
#   Step 5 — Kafka MirrorMaker2 (after both MSK clusters are up):
#     cd global/kafka_global && terraform init && terraform apply
