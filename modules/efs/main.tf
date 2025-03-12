# Storage Module - EFS

# Create EFS File System
resource "aws_efs_file_system" "efs" {
  creation_token   = "${var.project_name}-efs"
  encrypted        = true
  kms_key_id       = var.kms_key_arn # Use KMS key from Security Module
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" # Move to infrequent access after 30 days
  }

  tags = {
    Name = "${var.project_name}-efs"
  }
}

# Security Group for EFS - Only Allowing EC2 Instances
resource "aws_security_group" "efs_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id] # Only EC2 instances can access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-efs-sg"
  }
}

# Create EFS Mount Target in Each Private Subnet
resource "aws_efs_mount_target" "efs_mount" {
  count           = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnets[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

