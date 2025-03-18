# EC2 Instance for SSM-Based RDS Access
resource "aws_instance" "bastion" {
  ami           = "ami-08b5b3a93ed654d19" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = true
  security_groups = [aws_security_group.bastion_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Install PostgreSQL 15 from the official PostgreSQL repository
              sudo tee /etc/yum.repos.d/pgdg.repo <<EOT
              [pgdg15]
              name=PostgreSQL 15 for Amazon Linux 2
              baseurl=https://download.postgresql.org/pub/repos/yum/15/redhat/rhel-7-x86_64/
              enabled=1
              gpgcheck=0
              EOT
              
              sudo yum install -y postgresql15
              EOF
  tags = {
    Name = "bastion-host"
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH for backup access (Can be restricted)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for SSM Access
resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach SSM Managed Policy to Role
resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "rds_readonly_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}


# Create IAM Instance Profile for SSM
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}