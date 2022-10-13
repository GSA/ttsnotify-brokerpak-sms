variable "region" {
  type = string
}

variable "instance_name" {
  type    = string
  default = ""
}

variable "sender_id" {
  type = string
}

variable "monthly_spend_limit" {
  type        = number
  default     = 1
  description = "Amount, in USD, that the account is limited. Raising above 1 requires talking to AWS support"
}
