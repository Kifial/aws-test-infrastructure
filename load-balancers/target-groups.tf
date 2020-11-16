resource "aws_lb_target_group" "tf-test-tg" {
  name        = "tf-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path    = "/health"
    matcher = "200-299"
  }
}

resource "aws_lb_target_group" "tf-tx-tg" {
  name        = "tf-tx-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path    = "/health"
    matcher = "200-299"
  }
}
