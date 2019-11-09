output "instance_public_ip" {
  value = aws_instance.example.public_ip
}

//output "provisioner_private_key" {
//  value = tls_private_key.provisioner
//}
output "provisioner_private_key_pem" {
  value = tls_private_key.provisioner.private_key_pem
}
