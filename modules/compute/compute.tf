# Compute Module

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# IAM Policy for EC2
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.project_name}-ec2-policy"
  description = "Policy for EC2 instance to access required resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow EC2 to Read from S3 (If needed)
      # {
      #   Effect = "Allow"
      #   Action = [
      #     "s3:GetObject",
      #     "s3:ListBucket"
      #   ]
      #   Resource = [
      #     "arn:aws:s3:::${var.frontend_s3_bucket}",
      #     "arn:aws:s3:::${var.frontend_s3_bucket}/*"
      #   ]
      # },
      # Allow CloudWatch Logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# Launch Template for EC2 Instances
resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${var.project_name}-backend-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  //key_name      = var.ssh_key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash

# Update system and install necessary packages
sudo dnf update -y
sudo dnf install -y python3-pip git docker

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Set the correct home directory for ec2-user
cd /home/ec2-user

# Clone the GitHub repository
sudo git clone https://github.com/RohitManna11/3tier_python_todo_app.git

# Navigate to the backend directory
cd 3tier_python_todo_app/backend

# Install required Python dependencies
sudo pip3 install -r requirements.txt

# Build and run the Docker container
sudo docker build -t todo-backend .
sudo docker run -d -p 5000:5000 --name todo-backend-container todo-backend

EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "compute_asg" {
  vpc_zone_identifier = var.private_subnets
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
}

data "aws_instances" "compute_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.compute_asg.name]
  }
}