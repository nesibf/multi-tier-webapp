output "asg_name" {
  value = aws_autoscaling_group.compute_asg.name
}

output "ec2_instance_ids" {
  value = tolist([
    for instance in data.aws_instances.compute_instances.ids : instance
  ])
}


