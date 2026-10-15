output "private_key" {
  value       = tls_private_key.react_calculator_public_key.private_key_pem
  description = "Private key PEM for SSH to instances this template launches. Stored in this stack's state."
  sensitive   = true
}

output "launch_template_id" {
  value       = aws_launch_template.react_calculator.id
  description = "Launch template id consumed by the autoscaling stack."
}

output "server_port" {
  value       = var.server_port
  description = "Port the calculator listens on. The autoscaling stack uses this for the target group."
}
