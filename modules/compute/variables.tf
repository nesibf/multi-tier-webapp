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

variable "alb_security_group_id" {
  type = string
}

variable "ami_id" {
  type    = string
  default = "ami-05b10e08d247fb927"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "frontend_s3_bucket" {
  type = string
}
