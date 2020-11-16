output ecs_service_role {
  description =  "ECS Service Role"
  value = aws_iam_role.ecs_service_role
}

output ecs_service_role_policy {
  description = "ECS Service Role Policy"
  value = aws_iam_role_policy.ecs_service_role_policy
}

output ecs_task_execution_role {
  description = "ECS Task Execution Role"
  value = aws_iam_role.ecs_task_execution_role
}