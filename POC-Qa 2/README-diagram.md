project-infra/
│
├── global/
│   ├── route53_global_lb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── redis_global/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── kafka_global/   (MirrorMaker configs)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── region-us-gov-east-1/
│   ├── vpc/
│   ├── ecs/
│   ├── ecr/
│   ├── kafka/
│   ├── redis/
│   ├── alb/
│   └── main.tf
│
├── region-us-gov-west-1/
│   ├── vpc/
│   ├── ecs/
│   ├── ecr/
│   ├── kafka/
│   ├── redis/
│   ├── alb/
│   └── main.tf
│
├── modules/
│   ├── ecs/
│   ├── ecr/
│   ├── kafka/
│   ├── redis/
│   ├── redis_global/
│   ├── route53_global_lb/
│   └── alb/
│
└── .github/
    └── workflows/
        └── deploy-multi-region.yml









\

# Multi-Region Terraform Deployment Guide

This project deploys a multi-region GovCloud stack with regional application runtime and global routing/replication components.

## What Gets Deployed

1. Regional stack in East and West:
    1. ECR
    2. ECS Fargate application
    3. ALB
    4. MSK (Kafka)
    5. Redis
    6. API Gateway (regional, fronting ALB)
    7. Pending Updates DynamoDB table
2. Global stack:
    1. Global Redis replication
    2. Route53 latency-based DNS for ALB and optional API DNS
    3. Kafka MirrorMaker2 bidirectional replication

## Prerequisites

1. Terraform installed.
2. AWS GovCloud credentials exported in shell:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

3. Provider startup workaround (required in your environment):

```bash
export GODEBUG=asyncpreemptoff=1
```

4. Backend resources already created:
    1. S3 bucket: `accumulator-tf-state`
    2. DynamoDB table: `accumulator-tf-locks`

## Files You Must Fill

1. `region-us-gov-east1/terraform.tfvars`
2. `region-us-gov-west1/terraform.tfvars`
3. `global/redis_global/terraform.tfvars`
4. `global/route53_global_lb/terraform.tfvars`
5. `global/kafka_global/terraform.tfvars`

## Required Values

1. Regional networking:
    1. VPC IDs
    2. Private subnet IDs
    3. Security group IDs
2. Application/runtime:
    1. Image tag for app container
    2. MirrorMaker2 image URI
3. DNS:
    1. Hosted zone ID
    2. Domain names
4. Cross-region values (from regional outputs after apply):
    1. East/West ALB DNS and zone IDs
    2. East/West API Gateway hostnames
    3. East/West Kafka bootstrap brokers

## Apply Order (Must Follow)

1. East regional workspace
2. West regional workspace
3. Global Redis workspace
4. Global Route53 workspace
5. Global Kafka workspace

## Commands Per Workspace

Run these commands inside each workspace folder:

```bash
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Workspace Execution Sequence

```bash
export GODEBUG=asyncpreemptoff=1

cd region-us-gov-east1
terraform init && terraform validate && terraform plan -out=tfplan && terraform apply tfplan

cd ../region-us-gov-west1
terraform init && terraform validate && terraform plan -out=tfplan && terraform apply tfplan

cd ../global/redis_global
terraform init && terraform validate && terraform plan -out=tfplan && terraform apply tfplan

cd ../route53_global_lb
terraform init && terraform validate && terraform plan -out=tfplan && terraform apply tfplan

cd ../kafka_global
terraform init && terraform validate && terraform plan -out=tfplan && terraform apply tfplan
```

## Notes

1. Root `main.tf` is informational only. Do not run apply from root.
2. Use real values instead of `REPLACE_WITH_*` placeholders before plan/apply.
3. API DNS records are optional. Leave API fields empty in route53 tfvars if you do not want API latency records yet.
\
