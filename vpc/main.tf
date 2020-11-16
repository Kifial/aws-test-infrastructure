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