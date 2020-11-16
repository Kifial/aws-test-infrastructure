output tf_test_lb_dns {
  description = "Test LB DNS"
  value       = aws_lb.tf-test-lb.dns_name
}

output tf_tx_lb_dns {
  description = "TX LB DNS"
  value       = aws_lb.tf-tx-lb.dns_name
}

output tf_test_tg {
  description = "Test target group"
  value       = aws_lb_target_group.tf-test-tg
}

output tf_tx_tg {
  description = "TX target group"
  value       = aws_lb_target_group.tf-tx-tg
}
