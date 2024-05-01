resource "aws_lb" "wordpress-lb" {
  name               = "wordpress-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.load_balancer.id, aws_security_group.bastion-host-sg.id]
  subnets            = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
}

resource "aws_alb_target_group" "wordpress-tg" {
  name        = "wordpress-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    matcher             = "200"
    protocol            = "HTTP"
  }
}

resource "aws_autoscaling_attachment" "ec2_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ec2_cluster.id
  lb_target_group_arn    = aws_alb_target_group.wordpress-tg.arn
}

#resource "aws_alb_target_group_attachment" "wordpress" {
#  target_group_arn = aws_alb_target_group.wordpress-tg.arn
#  target_id        = aws_autoscaling_group.ec2_cluster.
#  depends_on       = [aws_alb_target_group.wordpress-tg]
#}

resource "aws_alb_listener" "ec2_alb_listener" {
  load_balancer_arn = aws_lb.wordpress-lb.arn
  port              = "80"
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.wordpress-tg]

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.wordpress-tg.arn
  }
}