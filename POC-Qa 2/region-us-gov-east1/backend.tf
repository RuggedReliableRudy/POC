terraform {
  backend "s3" {
    bucket         = "accumulator-tf-state"
    key            = "terraform/region-us-gov-east-1/accumulator.tfstate"
    region         = "us-gov-west-1"
    dynamodb_table = "accumulator-tf-locks"
    encrypt        = true
  }
}
