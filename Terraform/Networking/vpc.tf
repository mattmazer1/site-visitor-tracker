resource "aws_vpc" "psite" {
  cidr_block           = "10.0.0.0/28"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnets" {
  count      = length(local.public_subnet_cidrs)
  vpc_id     = aws_vpc.psite.id
  cidr_block = element(local.public_subnet_cidrs, count.index)
}

resource "aws_subnet" "private_subnets" {
  count      = length(local.private_subnet_cidrs)
  vpc_id     = aws_vpc.psite.id
  cidr_block = element(local.private_subnet_cidrs, count.index)
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.psite.id
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnets[*].id, 0)

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.psite.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnets[*].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.psite.id
  count  = length(local.public_subnet_cidrs)

  route {
    # cidr_block = element(local.private_subnet_cidrs, count.index)
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnets[*].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "frontend" {
  name        = "frontend-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = aws_vpc.psite.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = ["0.0.0.0/0"]
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = ["0.0.0.0/0"]
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "iphere"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_https" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = ["0.0.0.0/0"]
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

resource "aws_security_group" "server" {
  name        = "server-security-group"
  description = "Allow HTTPS and database traffic"
  vpc_id      = aws_vpc.psite.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = ["0.0.0.0/0"]
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_db" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = aws_subnet.private_subnets.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = ["0.0.0.0/0"]
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

resource "aws_security_group" "database" {
  name        = "database-security-group"
  description = "Allow HTTPS traffic"
  vpc_id      = aws_vpc.psite.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_access" {
  security_group_id = aws_security_group.database.id
  cidr_ipv4         = aws_subnet.private_subnets.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.database.id
  cidr_ipv4         = ["0.0.0.0/0"]
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

locals {
  public_subnet_cidrs  = ["10.0.1.0/28"]
  private_subnet_cidrs = ["10.0.2.0/28"]
}

