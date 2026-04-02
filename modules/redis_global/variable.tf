variable "app_name"   { type = string }
variable "env"        { type = string }

variable "east_vpc_id"     { type = string }
variable "east_subnet_ids" { type = list(string) }

variable "west_vpc_id"     { type = string }
variable "west_subnet_ids" { type = list(string) }
