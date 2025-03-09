variable "project_name" {
  type    = string
  default = "webapp"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "ec2_security_group_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}
