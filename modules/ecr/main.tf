resource "aws_ecr_repository" "this" {
  name = "${var.app_name}-${var.env}"

  image_scanning_configuration {
    scan_on_push = true
  }
}
