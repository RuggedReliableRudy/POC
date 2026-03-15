terraform {
  backend "s3" {
    bucket         = "your-tf-state-bucket"
    key            = "accumulator/terraform.tfstate"
    region         = "us-gov-west-1"
    dynamodb_table = "your-tf-lock-table"
    encrypt        = true
  }
}
