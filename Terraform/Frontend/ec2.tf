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
resource "aws_instance" "website_server" {
  ami           = data.aws_ami.latest_ami.id
  instance_type = "t2.micro"

  #add iam role 

  tags = {
    Name = "WebsiteSever"
  }
}
