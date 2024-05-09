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
  skip_final_snapshot  = true
}