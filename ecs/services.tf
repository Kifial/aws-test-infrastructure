resource "aws_ecs_service" "tf-test" {
  name            = "tf-test"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tf-test-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  depends_on      = [var.ecs_service_role_policy]

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.test_tg.arn
    container_name   = "tf-test-task"
    container_port   = 80
  }
}

resource "aws_ecs_service" "tf-tx" {
  name            = "tf-tx"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tf-tx-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  depends_on      = [var.ecs_service_role_policy]

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.tx_tg.arn
    container_name   = "tf-tx-task"
    container_port   = 80
  }
}
