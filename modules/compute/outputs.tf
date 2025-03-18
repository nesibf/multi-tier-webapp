output "asg_name" {
  value = aws_autoscaling_group.compute_asg.name
}

output "ec2_instance_ids" {
  value = tolist([
    for instance in data.aws_instances.compute_instances.ids : instance
  ])
}

output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "backend_ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}
