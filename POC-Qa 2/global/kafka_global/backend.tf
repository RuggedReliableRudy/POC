terraform {
  backend "s3" {
    bucket         = "accumulator-tf-state"
    key            = "terraform/global/kafka/accumulator.tfstate"
    region         = "us-gov-west-1"
    dynamodb_table = "accumulator-tf-locks"
    encrypt        = true
  }
}
