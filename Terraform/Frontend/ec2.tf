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

// have to think about how to link 
resource "aws_instance" "website_server" {
  ami                    = data.aws_ami.latest_ami.id
  instance_type          = "t2.micro"
  iam_instance_profile   = module.roles.aws_iam_instance_profile_name
  vpc_security_group_ids = aws_security_group.backend.id
  subnet_id              = aws_subnet.private_subnet.id

  tags = {
    Name = "ApiServer"
  }
}

resource "aws_eip" "ec2_eip" {
  instance = aws_instance.website_server.id
}
