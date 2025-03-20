# Security Module

# AWS Web Application Firewall (WAF) for ALB
resource "aws_waf_web_acl" "waf_acl" {
  name        = "${var.project_name}-waf"
  metric_name = "${var.project_name}metrics" # Required for WAF Classic

  default_action {
    type = "ALLOW" # Default action: Allow all traffic unless blocked
  }

  rules {
    action {
      type = "BLOCK" # Block bad requests
    }
    priority = 1
    rule_id  = aws_waf_rule.block_bad_requests.id
  }

  tags = {
    Name = "${var.project_name}-waf"
  }
}

# Security Group for ALB - Allow CloudFront
# resource "aws_security_group" "alb_sg" {
#   vpc_id = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-alb-sg"
#   }
# }

# Security Group for EFS - Allow EC2 Instances
# resource "aws_security_group" "efs_sg" {
#   vpc_id = var.vpc_id

#   ingress {
#     from_port       = 2049
#     to_port         = 2049
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ec2_sg.id] # Only EC2 instances can access
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-efs-sg"
#   }
# }

# KMS Key for Encryption
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for encrypting resources"
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "kms_alias" {
  name          = "alias/${var.project_name}-kms"
  target_key_id = aws_kms_key.kms_key.key_id
}

resource "aws_waf_rule" "block_bad_requests" {
  name        = "${var.project_name}-block-bad-requests"
  metric_name = "${var.project_name}metric"

  predicates {
    data_id = aws_waf_ipset.bad_ips.id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_waf_ipset" "bad_ips" {
  name = "${var.project_name}-bad-ips"

  ip_set_descriptors {
    type  = "IPV4"
    value = "192.0.2.0/24"
  }
}