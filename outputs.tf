output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "frontend_url" {
  value = "http://${module.cicd.frontend_s3_bucket}.s3-website-us-east-1.amazonaws.com"
}

output "alb_dns_name" {
  value = module.load_balancer.alb_dns_name
}