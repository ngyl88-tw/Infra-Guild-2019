data "aws_ami" "example" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/*/ubuntu-bionic-18.04-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
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

resource "aws_instance" "example" {
  ami           = data.aws_ami.example.id
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
      "set -xe",
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
