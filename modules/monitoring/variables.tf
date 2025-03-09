variable "project_name" {
  type    = string
  default = "webapp"
}

variable "alert_email" {
  type = string
}

variable "rds_instance_id" {
  type = string
}

variable "asg_name" {
  type = string
}
