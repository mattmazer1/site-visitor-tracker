resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
}

# TODO
#NAT gateway
#FIREWALL
#Subnets
#IP addresses
#DNS
#Assing each resoruce to sbunets and ips
#Secure credentials 
