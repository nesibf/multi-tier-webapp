terraform {
  required_providers {
    aws = {
      version = "5.89.0"
    }
  }

  backend "s3" {
    bucket         = "rohit11-terraform-backend-bucket"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}