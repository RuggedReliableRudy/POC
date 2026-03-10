################################################
# AWS & Account Settings
###############################################
region     = "us-gov-west-1"
account_id = "018743596699"

###############################################
# Networking
###############################################
vpc_id = "vpc-0bb67cf591eb840c2"

private_subnet_ids = [
  "subnet-for-10.247.234.224/28",
  "subnet-for-10.247.234.240/28",
  "subnet-for-10.247.232.64/27",
  "subnet-for-10.247.232.96/27"
]

db_subnet_group_name = "default-vpc-0bb67cf591eb840c2-new-dev"

###############################################
# ECS Settings
###############################################
desired_count = 2

# ECR image URIs
cpeload_image    = "018743596699.dkr.ecr.us-gov-west-1.amazonaws.com/project-accumulator:latest"
sql_runner_image = "018743596699.dkr.ecr.us-gov-west-1.amazonaws.com/project-accumulator:latest"

###############################################
# RDS Settings
###############################################
db_instance_class    = "db.m6g.large"
db_allocated_storage = 100

###############################################
# Application Database User
###############################################
app_user     = "app_user"
app_password = "CHANGE_ME_SECURELY"

###############################################
# Tags
###############################################
environment = "Dev"
repository  = "Project-Accumulator"

