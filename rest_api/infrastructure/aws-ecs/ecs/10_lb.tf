resource "aws_lb" "api_lb" {
  name            = "example-lb"
  subnets         = var.api_subnet[*].id
  security_groups = [var.api_lb_sg.id]
}

resource "aws_lb_target_group" "api_lb_tg" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "api_lb_list" {
  load_balancer_arn = aws_lb.api_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.api_lb_tg.arn
    type             = "forward"
  }
}
