output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "efs_security_group_id" {
  value = aws_security_group.efs_sg.id
}

output "kms_key_arn" {
  value = aws_kms_key.kms_key.arn
}

output "waf_acl_id" {
  value = aws_waf_web_acl.waf_acl.id
}
