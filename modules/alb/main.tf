resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_alb" "alb" {
  name            = var.alb_name
  subnets         = split(",", var.alb_subnets)
  security_groups = var.alb_security_groups
  internal        = var.internal_alb
  idle_timeout    = var.idle_timeout

  access_logs {
    bucket = var.s3_bucket
    prefix = "ELB-logs"
  }

  tags = {
    Name = var.alb_name
  }
}

variable "alb_security_groups" {
  description = "List of security group IDs to associate with the ALB"
  type        = list(string)
  default     = []
}

variable "alb_listener_port" {
  default = ""
}
variable "alb_listener_protocol" {
  default = ""
}
resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    target_group_arn = aws_alb_target_group.alb_target.arn
    type             = "forward"
  }
}

variable "priority" {
  default = ""
}
variable "alb_path" {
  default = ""
}
resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = [aws_alb_target_group.alb_target_group]
  listener_arn = aws_alb_listener.alb_listener.arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.id
  }

  condition {
    path_pattern {
      values = [var.alb_path]
    }
  }
}


resource "aws_alb_target_group" "alb_target_group" {
  name     = var.target_group_name
  port     = var.svc_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = var.target_group_sticky
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = var.target_group_path
    port                = var.target_group_port
  }

  tags = {
    Name = var.target_group_name
  }
}
