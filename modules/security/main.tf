# Security Module - Strictly Following Given Architecture

# AWS Web Application Firewall (WAF) for ALB
resource "aws_waf_web_acl" "waf_acl" {
  name        = "${var.project_name}-waf"
  metric_name = "${var.project_name}-waf-metrics"  # Required for WAF Classic
  default_action {
    type = "ALLOW"  # Default action: Allow all traffic unless blocked
  }

  rules {
    action {
      type = "BLOCK"  # Block requests that match this rule
    }

    priority = 1
    rule_id  = aws_waf_rule.block_bad_requests.id
    type     = "REGULAR"
  }
}

# Define WAF Rule to Block Bad Requests
resource "aws_waf_rule" "block_bad_requests" {
  name        = "${var.project_name}-waf-rule"
  metric_name = "${var.project_name}-waf-rule-metrics"  # Required for WAF Classic

  predicates {
    data_id = aws_waf_byte_match_set.trace_block.id
    negated = false
    type    = "ByteMatch"
  }
}

# Define Byte Match Set for Blocking TRACE Method
resource "aws_waf_byte_match_set" "trace_block" {
  name        = "${var.project_name}-byte-match"

  byte_match_tuples {
    field_to_match {
      type = "METHOD"  # Match HTTP method
    }

    target_string         = "TRACE"
    positional_constraint = "EXACTLY"
    text_transformation   = "NONE"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Only ALB can communicate with EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # Only EC2 instances can access RDS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS KMS Key for Encryption
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for encrypting RDS and EFS"
  deletion_window_in_days = 30
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}