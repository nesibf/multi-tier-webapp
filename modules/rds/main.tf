# Database Module

# Create Primary RDS Instance
resource "aws_db_instance" "primary" {
  identifier              = "${var.project_name}-rds-primary"
  engine                  = "postgres"
  engine_version          = "14.12"
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_encrypted       = true
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = true # set to true only when testing
  multi_az                = true
  backup_retention_period = 7
  skip_final_snapshot     = true


  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "${var.project_name}-rds-primary"
  }
}

# Create DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}
