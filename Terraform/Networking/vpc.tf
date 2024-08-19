resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/28"
  instance_tenancy = "default"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
}


#Routes
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.example.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "example"
  }
}

# TODO
#NAT gateway
#FIREWALL
#Subnets
#IP addresses
#DNS
#Assing each resoruce to sbunets and ips
#Secure credentials 
