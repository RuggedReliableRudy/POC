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
