repo-root/
│
├── cloudformation/
│   └── iam-roles.yaml
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
│
├── docker/
│   └── Dockerfile
│
└── .github/
    └── workflows/
        └── deploy.yml

cd /opt/actions-runner
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/latest/download/actions-runner-linux-x64.tar.gz
tar xzf actions-runner-linux-x64.tar.gz


./config.sh --url https://github.com/<org>/<repo> --token <runner-token>
sudo ./svc.sh install
sudo ./svc.sh start
sudo ./svc.sh status

execution

resource "aws_iam_role_policy" "ecs_execution_ecr" {
  name = "ecs-execution-ecr-pull"
  role = data.aws_iam_role.ecs_task_execution.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}



task

resource "aws_iam_role_policy" "ecs_task_s3_read" {
  name = "ecs-task-s3-read"
  role = data.aws_iam_role.ecs_task.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws-us-gov:s3:::your-bucket-name",
          "arn:aws-us-gov:s3:::your-bucket-name/*"
        ]
      }
    ]
  })
}



sql runner

resource "aws_iam_role_policy" "sql_runner_s3_read" {
  name = "sql-runner-s3-read"
  role = data.aws_iam_role.sql_runner.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws-us-gov:s3:::your-bucket-name",
          "arn:aws-us-gov:s3:::your-bucket-name/*"
        ]
      }
    ]
  })
}

