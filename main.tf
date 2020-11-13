terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile    = "default"
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_key_pair" "kifi" {
  key_name   = "kifi-key"
  public_key = file(var.ssh_pubkey_file)
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_route_table" "external" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "external-main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.external.id
}

resource "aws_route_table_association" "external-secondary" {
  subnet_id      = aws_subnet.secondary.id
  route_table_id = aws_route_table.external.id
}

# TODO: figure out how to support creating multiple subnets, one for each
# availability zone.
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone.main
}

resource "aws_subnet" "secondary" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone.secondary
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "load_balancers" {
  name        = "load_balancers"
  description = "Allows all traffic"
  vpc_id      = aws_vpc.main.id

  # TODO: do we need to allow ingress besides TCP 80 and 443?
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO: this probably only needs egress to the ECS security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "Allows all traffic"
  vpc_id      = aws_vpc.main.id

  # TODO: remove this and replace with a bastion host for SSHing into
  # individual machines.
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancers.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_cluster" "main" {
  name = "tf-test"
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = file("policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs_service_role.id
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "ecs_task_execution_role_policy"
  policy = file("policies/ecs-task-execution-role-policy.json")
  role   = aws_iam_role.ecs_task_execution_role.id
}
