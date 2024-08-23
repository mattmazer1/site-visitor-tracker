resource "aws_vpc" "psite" {
  cidr_block           = "10.0.0.0/27"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.psite.id
  cidr_block = local.public_subnet_cidrs
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.psite.id
  cidr_block = local.private_subnet_cidrs
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.psite.id
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_eip" "nat_eip" {
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.psite.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.psite.id

  route {
    cidr_block = local.private_subnet_cidrs
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "private_subnet_association" {

  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "frontend" {
  name        = "frontend-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = aws_vpc.psite.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "${local.IP_ADDRESS}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"
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
  cidr_ipv4         = aws_subnet.public_subnet.cidr_block //may have to use square brackets
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_db" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = aws_subnet.private_subnet.cidr_block
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
  cidr_ipv4         = aws_subnet.private_subnet.cidr_block
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

data "hcp_vault_secrets_app" "psite" {
  app_name = "psite-secrets"
}


locals {
  public_subnet_cidrs  = "10.0.0.0/28"
  private_subnet_cidrs = "10.0.0.16/28"
  IP_ADDRESS           = data.hcp_vault_secrets_app.psite.secrets["IP_ADDRESS"]
}

