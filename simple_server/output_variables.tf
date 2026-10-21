output "public_ip" {
  value       = aws_instance.react_calculator_ec2.public_ip
  description = "Public IP address of the web server."
}

output "public_dns" {
  value       = aws_instance.react_calculator_ec2.public_dns
  description = "Public DNS name of the web server."
}

output "app_url" {
  value       = "http://${aws_instance.react_calculator_ec2.public_dns}:${var.server_port}/"
  description = "Calculator URL. This stack publishes the instance port directly."
}

output "private_key" {
  value       = tls_private_key.react_calculator_public_key.private_key_pem
  description = "Private key PEM for SSH. Terraform stores it in this stack's state. ssh_to_host.sh writes it to a file outside the repo."
  sensitive   = true
}
