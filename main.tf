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

module "vpc" {
  source = "./vpc"
}

module "security_groups" {
  source = "./security-groups"

  vpc_id = module.vpc.id
}

module "iam" {
  source = "./iam"
}

module "load_balancers" {
  source = "./load-balancers"

  security_group_id = module.security_groups.load_balancer_security_group_id
  vpc_id            = module.vpc.id
  subnets           = module.vpc.subnets
}

module "ecs" {
  source = "./ecs"

  ecs_service_role_policy = module.iam.ecs_service_role_policy
  subnets                 = module.vpc.subnets
  ecs_security_group_id   = module.security_groups.ecs_security_group_id
  ecs_task_execution_role = module.iam.ecs_task_execution_role

  test_tg = module.load_balancers.tf_test_tg
  tx_tg   = module.load_balancers.tf_tx_tg
}

module "api_gateway" {
  source = "./api-gateway"

  test_lb_dns = module.load_balancers.tf_test_lb_dns
  tx_lb_dns   = module.load_balancers.tf_tx_lb_dns
}
