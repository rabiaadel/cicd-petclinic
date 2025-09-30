output "public_ip" {
  value = aws_instance.petclinic.public_ip
}

output "private_ip" {
  value = aws_instance.petclinic.private_ip
}
