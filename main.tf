provider "aws" {
  region = "us-east-1"
}

# Demo EC2 instance
resource "aws_instance" "demo" {
  ami = "ami-05b10e08d247fb927"
  instance_type = "t2.micro"
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

output "ec2_public_ip" {
  value = aws_instance.demo.public_ip
}