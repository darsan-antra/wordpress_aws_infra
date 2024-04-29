resource "aws_instance" "bastion" {
  ami           = "ami-04e5276ebb8451442"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.wordpress.key_name
  #  iam_instance_profile = aws_iam_instance_profile.session-manager.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.bastion-host-sg.id]
  subnet_id                   = aws_subnet.public_subnet_1a.id
  provisioner "local-exec" {
    command = "echo '${tls_private_key.bastion.private_key_pem}' > ./private1_key.pem"
  }
  user_data = <<-EOF
      sudo yum update -y
  EOF
  tags = {
    Name = "Bastion"
  }
}

resource "aws_launch_configuration" "wordpress_lb_launch_config" {
  name_prefix     = "wordpress_instance"
  image_id        = var.launch_config_ec2_ami
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.private_instance_SG.id]
  key_name        = aws_key_pair.wordpress.key_name
  #  iam_instance_profile = aws_iam_instance_profile.session-manager.id
  associate_public_ip_address = false
  user_data                   = <<-EOL
  #!/bin/bash -xe
  sudo yum -y update
  sudo yum install -y docker
  sudo service docker start
  sudo chmod 666 /var/run/docker.sock
  docker pull nginx
  docker tag nginx my-nginx
  docker run --rm --name nginx-server -d -p 80:80 -t my-nginx
  EOL
  depends_on                  = [aws_nat_gateway.nat_gateway1, aws_nat_gateway.nat_gateway2]
}

resource "aws_autoscaling_group" "ec2_cluster" {
  name                 = "wordpress_auto_scaling"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.wordpress_lb_launch_config.name
  vpc_zone_identifier  = [aws_subnet.private_subnet_1a_1.id, aws_subnet.private_subnet_1b_1.id]
  target_group_arns    = [aws_alb_target_group.wordpress-tg.arn]
}

resource "aws_key_pair" "wordpress" {
  public_key = tls_private_key.bastion.public_key_openssh
  key_name   = "wordpress_kp"
  provisioner "local-exec" {
    command = "echo '${tls_private_key.bastion.private_key_pem}' > ./private1_key.pem"
  }
}

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
