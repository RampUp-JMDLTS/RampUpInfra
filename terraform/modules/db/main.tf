resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "db_psw_name" {
  name = "db-password"
}

resource "aws_secretsmanager_secret_version" "db_psw_version" {
  secret_id     = aws_secretsmanager_secret.db_psw_name.id
  secret_string = random_password.master.result
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Epam RDS subnet group"
  }
}


resource "aws_security_group" "rds_sg" {
  name        = "epam-rds-sg"
  description = "Security group for RDS"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "db" {
  identifier           = var.db_instance_identifier
  allocated_storage    = var.db_allocated_storage
  db_name              = var.db_name
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = aws_secretsmanager_secret_version.db_psw_version.secret_string
  parameter_group_name = var.db_parameter_group_name
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
}