provider "aws" {
  region = "us-east-1"
}

# TERRAFORM VPC MODULE
module "vpc" {
  source             = "./modules/vpc"
  project_name       = "webapp"
  vpc_cidr           = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  aws_region         = "us-east-1"
}

# COMPUTE MODULE (EC2 + ASG)
module "compute" {
  source                = "./modules/compute"
  project_name          = "webapp"
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  alb_security_group_id = module.security.alb_security_group_id
  ami_id                = "ami-05b10e08d247fb927"
  instance_type         = "t2.micro"
  desired_capacity      = 2
  min_size              = 2
  max_size              = 4
  frontend_s3_bucket    = module.cicd.frontend_s3_bucket
  db_username           = "admin"
  db_password           = "admin"
  db_host               = module.rds.rds_endpoint
  db_name               = "todo_db"
  ssh_key_name          = "MyNewKey"
}

# LOAD BALANCER MODULE
module "load_balancer" {
  source              = "./modules/load_balancer"
  project_name        = "webapp"
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets
  ec2_instance_ids    = module.compute.ec2_instance_ids
  asg_name            = module.compute.asg_name
}

# MONITORING MODULE
module "monitoring" {
  source                     = "./modules/monitoring"
  project_name               = "webapp"
  alert_email                = "rkmanna11@gmail.com"
  rds_instance_id            = module.rds.rds_instance_id
  asg_name                   = module.compute.asg_name
  cloudfront_distribution_id = module.cicd.cloudfront_distribution_id
}

# RDS MODULE
module "rds" {
  source                = "./modules/rds"
  project_name          = "webapp"
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  ec2_security_group_id = module.security.ec2_security_group_id
  kms_key_arn           = module.security.kms_key_arn
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  db_username           = "dbadmin"
  db_password           = "dbadmin11"
}

# SECURITY MODULE
module "security" {
  source       = "./modules/security"
  project_name = "webapp"
  vpc_id       = module.vpc.vpc_id
}

# CICD MODULE
module "cicd" {
  source             = "./modules/cicd"
  aws_account_id     = "820242940122"
  aws_region         = "us-east-1"
  github_repo        = "RohitManna11/3tier_python_todo_app"
  s3_bucket          = "rohit11-terraform-backend-bucket"
  dynamodb_table     = "terraform-lock"
  frontend_s3_bucket = "react-python-todo-frontend"
}

## FOLLOWING RESOURCES HAVE BEEN REMOVED FROM STATE

# # S3 Bucket for Terraform State
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "rohit11-terraform-backend-bucket"
# #   lifecycle {
# #     prevent_destroy = true
# #   }
#   tags = {
#     Name = "Terraform State Bucket"
#   }
# }

# # S3 Bucket Versioning for Backend
# resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
#   bucket = "rohit11-terraform-backend-bucket"
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # DynamoDB Table for State Locking
# resource "aws_dynamodb_table" "terraform_locks" {
#   name         = "terraform-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   tags = {
#     Name = "Terraform Lock Table"
#   }
# }