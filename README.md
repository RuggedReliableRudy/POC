project-accumulator/
├── docker/
│   ├── Dockerfile
│   └── CpeLoad-0.1.jar   # <-- place your JAR here
│
├── terraform/
│   ├── backend.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│
└── .github/
    └── workflows/
        ├── build-push.yml
        └── terraform.yml
