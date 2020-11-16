resource "aws_lb_listener" "tf-test-listener" {
  load_balancer_arn = aws_lb.tf-test-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-test-tg.arn
  }
}

resource "aws_lb_listener" "tf-tx-listener" {
  load_balancer_arn = aws_lb.tf-tx-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-tx-tg.arn
  }
}