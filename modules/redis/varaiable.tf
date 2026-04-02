variable "app_name"   { type = string }
variable "env"        { type = string }
variable "vpc_id"     { type = string }
variable "subnet_ids" { type = list(string) }
variable "sg_ids"     { type = list(string) }
