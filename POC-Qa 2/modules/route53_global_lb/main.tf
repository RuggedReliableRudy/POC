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

resource "aws_route53_record" "api_east" {
  count   = var.api_record_name != "" && var.east_api_hostname != "" && var.west_api_hostname != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.api_record_name
  type    = "CNAME"
  ttl     = 60

  set_identifier = "api-us-gov-east-1"

  latency_routing_policy {
    region = "us-gov-east-1"
  }

  records = [var.east_api_hostname]
}

resource "aws_route53_record" "api_west" {
  count   = var.api_record_name != "" && var.east_api_hostname != "" && var.west_api_hostname != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.api_record_name
  type    = "CNAME"
  ttl     = 60

  set_identifier = "api-us-gov-west-1"

  latency_routing_policy {
    region = "us-gov-west-1"
  }

  records = [var.west_api_hostname]
}
