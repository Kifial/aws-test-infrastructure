resource "aws_lb" "tf-test-lb" {
  name            = "tf-test-lb"
  security_groups = [var.security_group_id]
  subnets         = var.subnets
}

resource "aws_lb" "tf-tx-lb" {
  name            = "tf-tx-lb"
  security_groups = [var.security_group_id]
  subnets         = var.subnets
}
