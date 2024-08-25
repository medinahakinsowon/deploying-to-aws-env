# Application Load Balancer Target group
resource "aws_lb_target_group" "appy_tg" {
  name        = "appy-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = "vpc-id goes here"
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

# Application Load Balancer
resource "aws_lb" "mainy" {
  name               = "appy-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["public-subnet1-id", "public-subnet2-id"]

  enable_deletion_protection = false

  tags = {
    Name = "app-lb"
  }
}

# Application Load Balancer Listener
resource "aws_lb_listener" "httpy" {
  load_balancer_arn = aws_lb.mainy.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# Load Balancer Listener for HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.mainy.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = certificate_arn_goes_here

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appy_tg.arn
  }
}
