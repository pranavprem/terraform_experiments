output "private_key" {
  value       = tls_private_key.react_calculator_public_key.private_key_pem
  description = "the public key that will be used for ssh"
  sensitive   = true
}

output "launch_config_name" {
  value = aws_launch_configuration.react_calculator_launch_config.name
  description = "Name of the launch configuration to be used as remote state in autoscaling loadbalancing"
}

output "server_port" {
  value = var.server_port
  description = "Port for server to be used as remote state in autoscaling loadbalancing"
}