terraform {
  backend "s3" {
    bucket = "project-accumulator-statefile"
    key    = "terraform/us-gov-west-1/infra.tfstate"
    region = "us-gov-west-1"
  }
}
