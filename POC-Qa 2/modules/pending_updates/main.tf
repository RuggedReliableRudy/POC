resource "aws_dynamodb_table" "this" {
  name         = "${var.app_name}-${var.env}-pending-updates"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "request_id"

  attribute {
    name = "request_id"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "${var.app_name}-${var.env}-pending-updates"
    Environment = var.env
    ManagedBy   = "terraform"
  }
}
