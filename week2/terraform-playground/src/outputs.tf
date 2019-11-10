output "ami_id" {
  value = data.aws_ami.example.id
}

output "instance_public_ip" {
  value = aws_instance.example.public_ip
}
