variable "name" {
  type    = string
  default = "last-stop"
}

variable "create_vpc" {
  type = bool
}

variable "allowlistRangeIPv4" {
  type = list(string)
}

variable "allowlistRangeIPv6" {
  type = list(string)
}

variable "vpc" {
  description = "optional vpc of your lambda"
  type = object({
    id = string
    cidr = string
    public_subnet_ids  = list(string)
    private_subnet_ids = list(string)
    security_group_ids = list(string)
    public_route_table_ids = list(string)
  })
  default = null
}
