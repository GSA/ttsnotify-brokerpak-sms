variable "region" {
  type = string
}

variable "user_name" { type = string }

variable "source_ips" {
  type = list(string)
}
