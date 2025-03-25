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

variable "bastion_security_group_id" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  type    = number
  default = 100
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}
