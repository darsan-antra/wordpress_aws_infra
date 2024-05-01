resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
  name = "test-db-password14"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result
}


resource "aws_secretsmanager_secret_version" "password1" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result

}


resource "aws_db_instance" "wordpress_db" {
  identifier = "dbwordpress"
  engine                 = "aurora-mysql"
  engine_version         = "5.7"
  db_name          = var.aurora_database_name
  username        = var.aurora_master_username
  password        = aws_secretsmanager_secret_version.password1.secret_string
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.id
  vpc_security_group_ids = [aws_security_group.aws_db_sg.id]
  skip_final_snapshot    = true
  instance_class         = "db.t2.small"
  allocated_storage = 100
  iops = 200
  parameter_group_name = "default.mysql5.7"
}