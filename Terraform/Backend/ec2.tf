data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
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
  iam_instance_profile   = var.instance_profile_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.private_subnet_id

  tags = {
    Name = "ApiServer"
  }
}
