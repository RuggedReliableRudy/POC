# -------------------------
# Networking
# -------------------------

vpc_id = "vpc-0faf5f1fb582102a6"

# ECS tasks run in private subnets
ecs_subnet_ids = [
  "subnet-0d8ee0c3b76df5791",
  "subnet-0d2dc7e4e190e15cd"
]

# RDS also uses private subnets
db_subnet_ids = [
  "subnet-0d8ee0c3b76df5791",
  "subnet-0d2dc7e4e190e15cd"
]

# -------------------------
# ECS Deployment
# -------------------------

desired_count = 2

ecr_uri   = "018743596699.dkr.ecr.us-gov-west-1.amazonaws.com/project-accumulator"
image_tag = "latest"
