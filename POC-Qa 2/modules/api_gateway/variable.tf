variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "stage_name" {
  type    = string
  default = "v1"
}
