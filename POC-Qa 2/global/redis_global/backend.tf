terraform {
  backend "s3" {
    bucket         = "accumulator-tf-state"
    key            = "terraform/global/redis/accumulator.tfstate"
    region         = "us-gov-west-1"
    dynamodb_table = "project-accumulator-tf-locks-dev"
    encrypt        = true
  }
}
