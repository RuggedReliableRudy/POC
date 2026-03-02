# -------------------------
# Networking
# -------------------------

vpc_id = "vpc-0faf5f1fb582102a6"

ecs_subnet_ids = [
  "subnet-0d8ee0c3b94df5735",
  "subnet-0d2dc9c4e190e15ae"
]

# RDS uses the same subnets as ECS
db_subnet_ids = [
  "subnet-0d8ee0c3b94df5735",
  "subnet-0d2dc9c4e190e15ae"
]

# -------------------------
# ECS Deployment
# -------------------------

desired_count = 2

# These two are passed from GitHub Actions normally,
# but you can set defaults here for local testing:
ecr_uri   = "123456789012.dkr.ecr.us-gov-west-1.amazonaws.com/project-accumulator"
image_tag = "latest"
