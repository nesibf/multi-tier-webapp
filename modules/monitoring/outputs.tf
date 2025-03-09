output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "ec2_logs_group_name" {
  value = aws_cloudwatch_log_group.ec2_logs.name
}

output "rds_logs_group_name" {
  value = aws_cloudwatch_log_group.rds_logs.name
}
