variable "project_name" {
  type    = string
  default = "webapp"
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "asg_name" {
  type = string
}
