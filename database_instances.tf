resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
  name = "test-db-password147"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result
}


resource "aws_secretsmanager_secret_version" "password1" {
  secret_id     = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result

}

# AWS database code block

#resource "aws_db_instance" "wordpress_db" {
#  identifier = "dbwordpress"
#  engine                 = "aurora-mysql"
#  engine_version         = "5.7"
#  db_name          = var.aurora_database_name
#  username        = var.aurora_master_username
#  password        = aws_secretsmanager_secret_version.password1.secret_string
#  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.id
#  vpc_security_group_ids = [aws_security_group.aws_db_sg.id]
#  skip_final_snapshot    = true
#  instance_class         = "db.t2.small"
#  allocated_storage = 100
#  iops = 200
#  parameter_group_name = "default.mysql5.7"
#}

resource "aws_launch_configuration" "wordpress_db" {
  name                        = "wordpress_db_instance"
  image_id                    = var.launch_config_ec2_ami
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.aws_db_sg.id]
  key_name                    = aws_key_pair.wordpress.key_name
  associate_public_ip_address = false
  user_data                   = <<-EOL
  #!/bin/bash -xe
  sudo yum update -y
  wget https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm
  sudo yum localinstall mysql84-community-release-el9-1.noarch.rpm -y
  sudo yum-config-manager --disable mysql-8.4-lts-community
  sudo yum-config-manager --disable mysql-tools-8.4-lts-community
  sudo yum-config-manager --enable mysql80-community
  sudo yum-config-manager --enable mysql-tools-community
  sudo yum install mysql-community-server -y
  sudo systemctl start mysqld
  sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}' > password.txt

  EOL

}

resource "aws_alb_target_group" "wordpress-db-tg" {
  name     = "wordpress-db-tg"
  port     = 3306
  protocol = "TCP"
  vpc_id   = aws_vpc.main_vpc.id
  health_check {
    port                = 3306
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    protocol            = "TCP"
  }
}

resource "aws_autoscaling_group" "db_cluster" {
  name_prefix          = "wordpress-db-instance"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.wordpress_db.name
  vpc_zone_identifier  = [aws_subnet.private_subnet_1a_2.id, aws_subnet.private_subnet_1b_2.id]
  target_group_arns    = [aws_alb_target_group.wordpress-db-tg.arn]


}

resource "aws_autoscaling_attachment" "wordpress_db_attachment" {
  autoscaling_group_name = aws_autoscaling_group.db_cluster.id
  lb_target_group_arn    = aws_alb_target_group.wordpress-db-tg.arn
}