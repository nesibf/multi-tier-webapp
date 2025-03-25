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