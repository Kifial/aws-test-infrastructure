resource "aws_lb" "tf-test-lb" {
  name                       = "tf-test-lb"
  security_groups            = [aws_security_group.load_balancers.id]
  subnets                    = [aws_subnet.main.id, aws_subnet.secondary.id]
  enable_deletion_protection = true
}

resource "aws_lb" "tf-tx-lb" {
  name                       = "tf-tx-lb"
  security_groups            = [aws_security_group.load_balancers.id]
  subnets                    = [aws_subnet.main.id, aws_subnet.secondary.id]
  enable_deletion_protection = true
}

# resource "aws_lb" "tf-nbl" {
#   name               = "tf-nlb"
#   internal           = true
#   load_balancer_type = "network"
#   subnets            = [aws_subnet.main.id, aws_subnet.secondary.id]
#   enable_deletion_protection = true
# }

resource "aws_lb_target_group" "tf-test-tg" {
  name        = "tf-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

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
  vpc_id      = aws_vpc.main.id

  health_check {
    path    = "/health"
    matcher = "200-299"
  }
}

resource "aws_lb_target_group" "tf-nlb-tg" {
  name        = "tf-nlb-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id
}

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

# resource "aws_lb_listener" "tf-nlb-listener" {
#   load_balancer_arn = aws_lb.tf-nlb-lb.arn
#   port              = "80"
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tf-nlb-tg.arn
#   }
# }

resource "aws_ecs_task_definition" "tf-test-task" {
  family                   = "tf-test-task"
  container_definitions    = file("task-definitions/tf-test-task.json")
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = ".5 vcpu"
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "tf-tx-task" {
  family                   = "tf-tx-task"
  container_definitions    = file("task-definitions/tf-tx-task.json")
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = ".5 vcpu"
  memory                   = 1024
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "tf-test" {
  name            = "tf-test"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.tf-test-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  depends_on      = [aws_iam_role_policy.ecs_service_role_policy]

  network_configuration {
    subnets          = [aws_subnet.main.id, aws_subnet.secondary.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tf-test-tg.arn
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
  depends_on      = [aws_iam_role_policy.ecs_service_role_policy]

  network_configuration {
    subnets          = [aws_subnet.main.id, aws_subnet.secondary.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tf-tx-tg.arn
    container_name   = "tf-tx-task"
    container_port   = 80
  }
}

resource "aws_api_gateway_rest_api" "main" {
  name        = "tf-main"
  description = "Terraform Test API"
}

# resource "aws_api_gateway_vpc_link" "main" {
#   name        = "tf-vpc-link"
#   description = "Terraform VPC Link"
#   target_arns = [aws_lb.tf-nlb.arn]

#   timeouts {
#     create = "20m"
#     delete = "20m"
#   }
# }

resource "aws_api_gateway_resource" "test" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "test"
}

resource "aws_api_gateway_resource" "test-proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.test.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "test-proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.test-proxy.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "test-proxy" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.test-proxy.id
  http_method             = aws_api_gateway_method.test-proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.tf-test-lb.dns_name}/{proxy}"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "tx" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "tx"
}

resource "aws_api_gateway_resource" "tx-proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_resource.tx.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "tx-proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.tx-proxy.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "tx-proxy" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.tx-proxy.id
  http_method             = aws_api_gateway_method.tx-proxy.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.tf-tx-lb.dns_name}/{proxy}"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}