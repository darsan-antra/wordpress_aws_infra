
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

resource "aws_instance" "wordpress_db" {
  ami                         = "ami-04ff98ccbfa41c9ad"
  instance_type               = "t2.small"
  security_groups             = [aws_security_group.aws_db_sg.id]
  key_name                    = aws_key_pair.wordpress.key_name
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.private_subnet_1a_2.id
  user_data                   = <<-EOL
  #!/bin/bash -xe
  cd /home/ec2-user/
  sudo yum update -y
  sudo amazon-linux-extras install mariadb10.5
  sudo systemctl start mariadb
  sudo rm -rf /etc/my.cnf
  echo "
  #
  # This group is read both both by the client and the server
  # use it for options that affect everything
  #
  [client-server]

  #
  # This group is read by the server
  #
  [mysqld]
  # Disabling symbolic-links is recommended to prevent assorted security risks
  symbolic-links=0
  bind-address = 0.0.0.0
  #
  # include all files from the config directory
  #
  !includedir /etc/my.cnf.d
  " > /etc/my.cnf
  sudo systemctl restart mysql

#  mysql_secure_installation
#  read ${aws_secretsmanager_secret_version.password.secret_string}
  mysql -u root -p`${aws_secretsmanager_secret_version.password.secret_string}` <<EOF
  CREATE USER 'admin'@'%' IDENTIFIED BY `${aws_secretsmanager_secret_version.password.secret_string}`;
  CREATE DATABASE `${var.database_name}`;
  GRANT ALL PRIVILEGES ON `${var.database_name}`.* TO "admin"@"%";
  FLUSH PRIVILEGES;
  EOF
  EOL
  tags = {
    Name = "wordpress_db"
  }
}

#resource "aws_launch_configuration" "wordpress_db" {
#  name                        = "wordpress_db_instance"
#  image_id                    = var.launch_config_ec2_ami
#  instance_type               = "t2.micro"
#  security_groups             = [aws_security_group.aws_db_sg.id]
#  key_name                    = aws_key_pair.wordpress.key_name
#  associate_public_ip_address = false
#  user_data                   = <<-EOL
##!/bin/bash -xe
#cd /home/ec2-user/
#sudo yum update -y
#sudo yum install jq -y
#sudo wget https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm
#sudo yum localinstall mysql84-community-release-el9-1.noarch.rpm -y
#sudo yum-config-manager --disable mysql-8.4-lts-community
#sudo yum-config-manager --disable mysql-tools-8.4-lts-community
#sudo yum-config-manager --enable mysql80-community
#sudo yum-config-manager --enable mysql-tools-community
#sudo yum install mysql-community-server -y
#sudo systemctl start mysqld
#sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}' > password.txt
#  EOL
#}
#
## 'Newpass1!'
## veera@localhost : 'NewPass1!'
#
#resource "aws_alb_target_group" "wordpress-db-tg" {
#  name     = "wordpress-db-tg"
#  port     = 3306
#  protocol = "TCP"
#  vpc_id   = aws_vpc.main_vpc.id
#  health_check {
#    port                = 3306
#    healthy_threshold   = 2
#    unhealthy_threshold = 3
#    timeout             = 5
#    interval            = 30
#    protocol            = "TCP"
#  }
#}
#
#resource "aws_autoscaling_group" "db_cluster" {
#  name_prefix          = "wordpress-db-instance"
#  min_size             = 1
#  max_size             = 1
#  desired_capacity     = 1
#  health_check_type    = "EC2"
#  launch_configuration = aws_launch_configuration.wordpress_db.name
#  vpc_zone_identifier  = [aws_subnet.private_subnet_1a_2.id, aws_subnet.private_subnet_1b_2.id]
#  target_group_arns    = [aws_alb_target_group.wordpress-db-tg.arn]
#
#
#}
#
#resource "aws_autoscaling_attachment" "wordpress_db_attachment" {
#  autoscaling_group_name = aws_autoscaling_group.db_cluster.id
#  lb_target_group_arn    = aws_alb_target_group.wordpress-db-tg.arn
#}