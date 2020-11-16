output id {
  description = "VPC id"
  value = aws_vpc.main.id
}

output subnets {
  description = "Subnets"
  value = [aws_subnet.main.id, aws_subnet.secondary.id]
}