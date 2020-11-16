output load_balancer_security_group_id {
  description = "Load Balancer security group"
  value       = aws_security_group.load_balancers.id
}

output ecs_security_group_id {
  description = "ECS Security Group"
  value       = aws_security_group.ecs.id
}
