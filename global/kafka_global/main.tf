terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-gov-east-1"
}

variable "app_name" {}
variable "env" {}

variable "east_bootstrap_brokers" {}
variable "west_bootstrap_brokers" {}

# Here you’d define an ECS service or EC2 instance running MirrorMaker 2
# using east_bootstrap_brokers and west_bootstrap_brokers.
