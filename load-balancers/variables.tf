variable security_group_id {
  description = "Security Group id"
  type        = string
}

variable subnets {
  description = "Load balancer subnets"
  type        = list(string)
}

variable vpc_id {
  description = "VPC id"
  type        = string
}
