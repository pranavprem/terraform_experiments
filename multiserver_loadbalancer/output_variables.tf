output "private_key" {
  value       = tls_private_key.react_calculator_public_key.private_key_pem
  description = "Private key PEM for SSH to the instances. Terraform stores it in this stack's state."
  sensitive   = true
}

output "public_ips" {
  value       = data.aws_instances.workers.public_ips
  description = "Public IPs of instances tagged react_calculator_asg. Empty until the group finishes launching."
}

output "alb_dns_name" {
  value       = aws_lb.react_calculator_lb.dns_name
  description = "Domain name of the load balancer."
}

output "app_url" {
  value       = "http://${aws_lb.react_calculator_lb.dns_name}/"
  description = "Calculator URL via the load balancer."
}
