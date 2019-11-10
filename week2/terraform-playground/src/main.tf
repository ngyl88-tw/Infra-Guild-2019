resource "aws_instance" "example" {
  ami           = "ami-0c199cae95cea87f0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.provisioner.key_name # implicit depends_on for provisioner key

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    timeout     = "2m"
    private_key = tls_private_key.provisioner.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /tmp/init"
    ]
  }

  provisioner "file" {
    source      = "../resources/test.properties"
    destination = "/home/ubuntu/test.properties"
  }

  provisioner "file" {
    source      = "../resources/init/"
    destination = "/tmp/init"
  }

  # speed up by grouping remote commands to avoid multiple ssh
  # sudo required to run all commands in script
  # reconfigure ssh permissions: remove provisioner key and setup authorized_keys
  provisioner "remote-exec" {
    inline = [
      "chmod g+x /tmp/init/bootstrap.sh",
      "sudo /tmp/init/bootstrap.sh",
      "echo ${var.ssh_public_key} > /home/ubuntu/.ssh/authorized_keys"
    ]
  }

  tags = {
    Name = "infra-guild-week2"
  }
}

# For provisioner connection
resource "tls_private_key" "provisioner" {
  algorithm = "RSA"
}

resource "aws_key_pair" "provisioner" {
  key_name   = var.provisioner_key_name
  public_key = tls_private_key.provisioner.public_key_openssh
}

# Get default vpc so that we can access the instance
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = data.aws_security_group.default.id

  cidr_blocks = var.whitelisted_cidrs
  description = "infra-guild-week2: allow SSH from Office and Home IP"
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = data.aws_security_group.default.id

  cidr_blocks = var.whitelisted_cidrs
  description = "infra-guild-week2: allow http call from Office and Home IP"
}