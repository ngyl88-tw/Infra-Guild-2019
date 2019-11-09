provider "aws" {
  region     = "ap-southeast-1"
}

# Create a new AWS Instance
resource "aws_instance" "example" {
  ami           = "ami-061eb2b23f9f8839c"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.ssh_public_key
}

# Get default vpc so that we can access the instance
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  security_group_id = data.aws_security_group.default.id

  cidr_blocks = var.whitelisted_cidrs
  description = "Allow SSH from Office IP"
}