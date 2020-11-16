variable ecs_cluster_name {
  description = "The name of the Amazon ECS cluster."
  default     = "tf-test"
}

variable ecs_service_role_policy {
  description = "ECS Service Role Policy"
}

variable subnets {
  description = "Subnets"
  type        = list(string)
}

variable ecs_security_group_id {
  description = "ECS Security Group id"
  type        = string
}

variable ecs_task_execution_role {
  description = "ECS Task Execution Role"
}

variable test_tg {
  description = "Test target group"
}

variable tx_tg {
  description = "TX target group"
}
