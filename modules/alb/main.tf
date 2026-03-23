resource "aws_lb" "this" {
  name               = "${var.app_name}-${var.env}-alb"
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.sg_ids
}

resource "aws_lb_target_group" "this" {
  name     = "${var.app_name}-${var.env}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
