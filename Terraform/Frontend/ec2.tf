module "roles" {
  source = "../Roles"
}
data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#need to link security group here
resource "aws_instance" "website_server" {
  ami                  = data.aws_ami.latest_ami.id
  instance_type        = "t2.micro"
  iam_instance_profile = module.roles.aws_iam_instance_profile_name

  tags = {
    Name = "WebsiteSever"
  }
}
resource "aws_eip" "nat_eip" {
  domain   = "vpc"
  instance = aws_instance.website_server.id
}
