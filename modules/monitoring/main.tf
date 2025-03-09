# Monitoring Module

data "aws_autoscaling_group" "asg" {
  name = var.asg_name
}

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
  endpoint  = var.alert_email # Email where alerts will be sent
}

# CloudWatch Alarm for High CPU Usage on EC2
resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80 # Alarm triggers if CPU usage > 80%
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = data.aws_instances.ec2_instances.ids[0] # First instance ID
  }
}

# CloudWatch Alarm for High Memory Usage on EC2
resource "aws_cloudwatch_metric_alarm" "ec2_high_memory" {
  alarm_name          = "${var.project_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80 # Alarm triggers if Memory usage > 80%
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = data.aws_instances.ec2_instances.ids[1] # Second instance ID
  }

}

# CloudWatch Alarm for RDS Free Storage Space
resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${var.project_name}-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5000000000 # Alarm triggers if storage < 5GB
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
}

# CloudWatch Logs Group for EC2 Instances
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "${var.project_name}-ec2-logs"
  retention_in_days = 30
}

# CloudWatch Logs Group for RDS Logs
resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "${var.project_name}-rds-logs"
  retention_in_days = 30
}