# Database Module

# Create Primary RDS Instance
resource "aws_db_instance" "primary" {
  identifier              = "${var.project_name}-rds-primary"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_encrypted       = true
  kms_key_id              = var.kms_key_arn  # Use KMS key from Security Module
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = false
  multi_az                = true  # Ensures high availability
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "${var.project_name}-rds-primary"
  }
}

# Create RDS Read Replica
resource "aws_db_instance" "replica" {
  identifier              = "${var.project_name}-rds-replica"
  engine                  = aws_db_instance.primary.engine
  instance_class          = var.instance_class
  storage_encrypted       = true
  kms_key_id              = var.kms_key_arn
  replicate_source_db     = aws_db_instance.primary.identifier
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "${var.project_name}-rds-replica"
  }
}

# Create RDS Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306  # MySQL port
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]  # Only EC2 instances can access RDS
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

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

