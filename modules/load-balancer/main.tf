resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  description = "Security group for ${var.name} ALB"
  vpc_id      = var.vpc_id

  # Single dynamic block for all rules
  dynamic "ingress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "ingress"]
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      self            = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.security_group_rules : rule if rule.type == "egress"]
    content {
      description     = egress.value.description
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
      self            = egress.value.self
    }
  }

  tags = {
    Name = "${var.name}-alb-sg"
  }
}
resource "aws_lb" "load_balancer" {
  name               = "${var.name}-alb"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type # Use "application" for HTTP/S traffic
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = var.idle_timeout

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.name}-tg"
  port        = var.target_port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path                = var.healthCheck_path
    matcher             = var.matcher
    interval            = var.healthcheck_interval
    port                = var.target_port
    protocol            = var.protocol
    healthy_threshold   = var.healthcheck_healthy_threshold
    unhealthy_threshold = var.healthcheck_unhealthy_threshold
    timeout             = var.healthcheck_healthy_timeout
  }
  tags = {
    Name = "${var.name}-tg"
  }
}


resource "aws_lb_listener" "tcp_listner" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.target_port
  protocol          = var.protocol

  default_action {
    type             = var.action_type
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}