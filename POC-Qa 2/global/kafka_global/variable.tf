variable "app_name" { type = string }
variable "env" { type = string }
variable "east_bootstrap_brokers" { type = string }
variable "west_bootstrap_brokers" { type = string }
variable "mm2_image" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
