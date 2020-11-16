resource "aws_ecs_task_definition" "tf-test-task" {
  family                   = "tf-test-task"
  container_definitions    = file("task-definitions/tf-test-task.json")
  task_role_arn            = var.ecs_task_execution_role.arn
  execution_role_arn       = var.ecs_task_execution_role.arn
  cpu                      = ".5 vcpu"
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "tf-tx-task" {
  family                   = "tf-tx-task"
  container_definitions    = file("task-definitions/tf-tx-task.json")
  task_role_arn            = var.ecs_task_execution_role.arn
  execution_role_arn       = var.ecs_task_execution_role.arn
  cpu                      = ".5 vcpu"
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}
