resource "aws_route53_record" "east" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "us-gov-east-1"

  latency_routing_policy {
    region = "us-gov-east-1"
  }

  alias {
    name                   = var.east_alb_dns
    zone_id                = var.east_alb_zone
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "west" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "us-gov-west-1"

  latency_routing_policy {
    region = "us-gov-west-1"
  }

  alias {
    name                   = var.west_alb_dns
    zone_id                = var.west_alb_zone
    evaluate_target_health = true
  }
}
