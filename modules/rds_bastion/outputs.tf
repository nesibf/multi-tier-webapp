# Output Bastion Instance ID
output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_ssm_session" {
  description = "SSM Session URL for Bastion Host"
  value       = "https://console.aws.amazon.com/systems-manager/session-manager/${aws_instance.bastion.id}"
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}