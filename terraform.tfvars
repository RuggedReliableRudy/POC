vpc_id = "vpc-0bb67cf591eb840c2"

private_subnet_ids = [
  "subnet-for-10.247.234.224/28",
  "subnet-for-10.247.234.240/28",
  "subnet-for-10.247.232.64/27",
  "subnet-for-10.247.232.96/27"
]

db_subnet_group_name = "default-vpc-0bb67cf591eb840c2-new-dev"

desired_count = 2

ecr_uri   = "018743596699.dkr.ecr.us-gov-west-1.amazonaws.com/project-accumulator"
image_tag = "latest"

account_id = "018743596699"
