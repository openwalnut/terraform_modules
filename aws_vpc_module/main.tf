resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  count             = length(var.public_subnets)
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_eip" "nat" {
  count      = length(var.public_subnets)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count         = length(var.public_subnets)
  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  depends_on    = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  count  = length(var.private_subnets)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.this[*].id, count.index)
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public[*].id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  route_table_id = element(aws_route_table.private[*].id, count.index)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
}
