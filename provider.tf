terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "your-tf-state-bucket-gov"
    key    = "infra/west/terraform.tfstate"
    region = "us-gov-west-1"
  }
}

provider "aws" {
  region = "us-gov-west-1"
}
