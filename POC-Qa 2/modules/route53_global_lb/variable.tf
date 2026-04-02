variable "domain_name" { type = string }
variable "hosted_zone_id" { type = string }
variable "east_alb_dns" { type = string }
variable "east_alb_zone" { type = string }
variable "west_alb_dns" { type = string }
variable "west_alb_zone" { type = string }

variable "api_record_name" {
  type    = string
  default = ""
}

variable "east_api_hostname" {
  type    = string
  default = ""
}

variable "west_api_hostname" {
  type    = string
  default = ""
}
