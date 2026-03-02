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



╷
│ Error: reading IAM Role (project-cpeload-sql-runner-role): couldn't find resource
│
│   with data.aws_iam_role.sql_runner,
│   on main.tf line 137, in data "aws_iam_role" "sql_runner":
│ 137: data "aws_iam_role" "sql_runner" {
│
╵
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
 
╷
│ Error: reading IAM Role (project-cpeload-ecs-task-execution-role): couldn't find resource
│
│   with data.aws_iam_role.ecs_task_execution,
│   on main.tf line 129, in data "aws_iam_role" "ecs_task_execution":
│ 129: data "aws_iam_role" "ecs_task_execution" {
│
╵
╷
│ Error: reading IAM Role (project-cpeload-ecs-task-role): couldn't find resource
│
│   with data.aws_iam_role.ecs_task,
│   on main.tf line 133, in data "aws_iam_role" "ecs_task":
│ 133: data "aws_iam_role" "ecs_task" {
│
╵
 

