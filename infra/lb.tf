resource "aws_lb" "alb" {
  name               = local.lb.name
  internal           = local.lb.internal
  load_balancer_type = "application"
  subnets            = data.aws_subnets.subnets.ids

  depends_on = [
    data.aws_subnets.subnets
  ]
}

resource "aws_lb_target_group" "group" {
  name        = local.lb.target_group.name
  port        = local.lb.target_group.port
  protocol    = local.lb.target_group.protocol
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  depends_on = [
    aws_lb.alb
  ]
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.group.arn
  }

  depends_on = [
    aws_lb.alb
  ]
}
