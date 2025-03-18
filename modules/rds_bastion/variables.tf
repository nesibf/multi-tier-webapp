variable "ami_id" {
  description = "AMI ID for the Bastion Host"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the Bastion Host"
  type        = string
  default     = "t2.micro"
}

variable "public_subnet_id" {
  description = "Public subnet ID for the Bastion Host"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}
