output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "bastion_ssm_session" {
  description = "SSM Session URL for Bastion Host"
  value       = module.rds_bastion.bastion_ssm_session
}

output "compute" {
  value = module.compute.backend_ec2_sg_id
}
