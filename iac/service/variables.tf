variable "name" {
  type    = string
  default = "last-stop"
}

variable "create_vpc" {
  type = bool
}

variable "vpc_config" {
  description = "optional vpc of your lambda"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}
