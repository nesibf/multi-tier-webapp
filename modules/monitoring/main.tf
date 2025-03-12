# Monitoring Module

# Fetch Auto Scaling Group Data
data "aws_autoscaling_group" "asg" {
  name = var.asg_name
}

# Fetch EC2 Instances in ASG
data "aws_instances" "ec2_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [data.aws_autoscaling_group.asg.name]
  }
}

# Create SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

# Subscribe Email to SNS Topic
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Log Group for EC2 Logs
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/aws/ec2/${var.project_name}-backend"
  retention_in_days = 30
}

# CloudWatch Log Group for RDS Logs
resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/aws/rds/${var.project_name}-database"
  retention_in_days = 30
}

# CloudWatch Log Group for CloudFront Access Logs
resource "aws_cloudwatch_log_group" "cloudfront_logs" {
  name              = "/aws/cloudfront/${var.project_name}-frontend"
  retention_in_days = 30
}

# CloudFront Logs to CloudWatch
resource "aws_cloudwatch_log_stream" "cloudfront_stream" {
  name           = "cloudfront-access-logs"
  log_group_name = aws_cloudwatch_log_group.cloudfront_logs.name
}

# CloudWatch Alarm for High CPU on EC2 Instances
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Triggers if CPU usage exceeds 75% for 2 consecutive minutes."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# CloudWatch Alarm for RDS High Connections
resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  alarm_name          = "${var.project_name}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 100
  alarm_description   = "Triggers if RDS connections exceed 100 for 2 consecutive minutes."
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}
