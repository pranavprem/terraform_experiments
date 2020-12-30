output "public_ip" {
  value       = aws_instance.react_calculator_ec2.public_ip
  description = "The public IP address of the web server"
}

output "public_dns" {
  value       = aws_instance.react_calculator_ec2.public_dns
  description = "The public DNS of the web server"
}

output "private_key" {
  value       = tls_private_key.react_calculator_public_key.private_key_pem
  description = "the public key that will be used for ssh"
}