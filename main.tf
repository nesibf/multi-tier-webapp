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
  alb_security_group_id = module.load_balancer.alb_security_group_id
  ami_id                = "ami-05b10e08d247fb927"
  instance_type         = "t2.micro"
  desired_capacity      = 2
  min_size              = 2
  max_size              = 4
  frontend_s3_bucket    = module.cicd.frontend_s3_bucket
}

# LOAD BALANCER MODULE
module "load_balancer" {
  source           = "./modules/load_balancer"
  project_name     = "webapp"
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnets
  ec2_instance_ids = module.compute.ec2_instance_ids
  asg_name         = module.compute.asg_name
}

# MONITORING MODULE
module "monitoring" {
  source                     = "./modules/monitoring"
  project_name               = "webapp"
  alert_email                = "rkmanna11@gmail.com"
  rds_instance_id            = module.rds.rds_instance_id
  asg_name                   = module.compute.asg_name
}

# RDS MODULE
module "rds" {
  source                    = "./modules/rds"
  project_name              = "webapp"
  vpc_id                    = module.vpc.vpc_id
  private_subnets           = module.vpc.private_subnets
  ec2_security_group_id     = module.compute.backend_ec2_sg_id
  bastion_security_group_id = module.rds_bastion.bastion_sg_id
  instance_class            = "db.t3.micro"
  allocated_storage         = 20
  max_allocated_storage     = 100
  db_username               = "dbadmin"
  db_password               = "dbadmin11"
}

# RDS Bastion Module for testing
module "rds_bastion" {
  source           = "./modules/rds_bastion"
  ami_id           = "ami-08b5b3a93ed654d19" # Amazon Linux 2 AMI
  instance_type    = "t2.micro"
  public_subnet_id = module.vpc.public_subnets[0]
  vpc_id           = module.vpc.vpc_id
}

module "efs" {
  source                = "./modules/efs"
  project_name          = "webapp"
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  ec2_security_group_id = module.compute.backend_ec2_sg_id
  kms_key_arn           = module.security.kms_key_arn
}


# SECURITY MODULE
module "security" {
  source       = "./modules/security"
  project_name = "webapp"
  vpc_id       = module.vpc.vpc_id
}

# CICD MODULE
# module "cicd" {
#   source             = "./modules/cicd"
#   aws_account_id     = "820242940122"
#   aws_region         = "us-east-1"
#   github_repo        = "RohitManna11/3tier_python_todo_app"
#   s3_bucket          = "rohit11-terraform-backend-bucket"
#   dynamodb_table     = "terraform-lock"
#   frontend_s3_bucket = "react-python-todo-frontend"
# }

## BELOW RESOURCES TO BE USED FOR BACKEND TESTING ONLY

# UPDATED SECURITY GROUP TO ALLOW SSM ACCESS
# resource "aws_security_group_rule" "allow_ssm_inbound" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   security_group_id = module.compute.backend_ec2_sg_id
#   cidr_blocks       = ["0.0.0.0/0"] # Restrict to AWS IPs in production
# }

# UPDATED IAM POLICY FOR EC2 TO ALLOW SSM
# resource "aws_iam_role_policy_attachment" "ssm_managed" {
#   role       = module.compute.ec2_role_name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

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