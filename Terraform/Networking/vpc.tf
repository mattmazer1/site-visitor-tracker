resource "aws_vpc" "psite" {
  cidr_block           = "10.0.0.0/26"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.psite.id
  cidr_block        = local.public_subnet_cidrs
  availability_zone = "ap-southeast-2a"
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.psite.id
  cidr_block        = local.private_subnet_cidrs
  availability_zone = "ap-southeast-2b"
}

resource "aws_subnet" "db_backup_subnet" {
  vpc_id            = aws_vpc.psite.id
  cidr_block        = local.private_db_backup_subnet_cidrs
  availability_zone = "ap-southeast-2c"
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
    cidr_block = "0.0.0.0/0" #TODO shouldn't this be public subent cidr? ---------------------------------------------
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

resource "aws_vpc_security_group_ingress_rule" "allow_frontend_http" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "allow_frontend_https" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_frontend_ssh" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "${local.IP_ADDRESS}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_frontend_outbound" {
  security_group_id = aws_security_group.frontend.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}



resource "aws_security_group" "server" {
  name        = "server-security-group"
  description = "Allow HTTPS, database and SSH traffic"
  vpc_id      = aws_vpc.psite.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_server_https" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = aws_subnet.public_subnet.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_server_to_db" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = aws_subnet.private_subnet.cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_ingress_rule" "allow_server_ssh" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "${local.IP_ADDRESS}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_server_outbound" {
  security_group_id = aws_security_group.server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

resource "aws_security_group" "database" {
  name        = "database-security-group"
  description = "Allow server traffic"
  vpc_id      = aws_vpc.psite.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_access" {
  security_group_id = aws_security_group.database.id
  cidr_ipv4         = aws_subnet.private_subnet.cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "allow_all_db_outbound" {
  security_group_id = aws_security_group.database.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

output "public_subnet" {
  description = "Public subnet"
  value       = aws_subnet.public_subnet
}

output "private_subnet" {
  description = "Private subnet"
  value       = aws_subnet.private_subnet
}

output "private_db_backup_subnet" {
  description = "Private backup database subnet"
  value       = aws_subnet.db_backup_subnet
}

output "server_security_group" {
  description = "Server security group"
  value       = aws_security_group.server
}

output "frontend_security_group" {
  description = "Frontend security group"
  value       = aws_security_group.frontend
}

output "database_security_group" {
  description = "Database security group"
  value       = aws_security_group.database
}

data "hcp_vault_secrets_app" "psite" {
  app_name = "psite-secrets"
}

locals {
  public_subnet_cidrs            = "10.0.0.0/28"
  private_subnet_cidrs           = "10.0.0.16/28"
  private_db_backup_subnet_cidrs = "10.0.0.32/28"
  IP_ADDRESS                     = data.hcp_vault_secrets_app.psite.secrets["IP_ADDRESS"]
}

