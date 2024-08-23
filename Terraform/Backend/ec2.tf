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

resource "aws_instance" "site_api" {
  ami                    = data.aws_ami.latest_ami.id
  instance_type          = "t2.micro"
  iam_instance_profile   = module.roles.aws_iam_instance_profile_name
  vpc_security_group_ids = aws_security_group.frontend.id
  subnet_id              = aws_subnet.public_subnet.id

  tags = {
    Name = "WebsiteServer"
  }
}

resource "aws_eip" "ec2_eip" {
  instance = aws_instance.website_server.id
}
