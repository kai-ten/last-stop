variable "name" {
  description = "Name of the project"
  type        = string
}

variable "region" {
  description = "Region of your deployment"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "allowlistRangeIPv4" {
  type = list(string)
}

variable "allowlistRangeIPv6" {
  type = list(string)
}

variable "audit_log_lambda_arn" {
  description = "The ARN value of the audit log service."
  type = string
}

variable "gpt3cc_lambda_arn" {
  description = "The ARN value of the GPT-3 Chat Completion service."
  type = string
}

variable "vpc_config" {
  description = "optional vpc of your lambda"
  type = object({
    vpc_id = string
    vpc_cidr = string
    public_subnet_ids = list(string)
    security_group_ids = list(string)
    public_route_table_ids = list(string)
  })
  default = null
}
