variable "vpc_config" {
  description = "optional vpc of your lambda"
  type = object({
    vpc_id = string
    vpc_cidr = string
    public_subnet_ids = list(string)
    security_group_ids = list(string)
  })
  default = null
}