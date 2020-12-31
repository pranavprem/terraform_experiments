output "private_key" {
  value       = tls_private_key.react_calculator_public_key.private_key_pem
  description = "the public key that will be used for ssh"
  sensitive   = true
}

output "public_ips" {
  value = data.aws_instances.workers.public_ips
}

output "alb_dns_name" {
  value       = aws_lb.react_calculator_lb.dns_name
  description = "The domain name of the load balancer"
}



data "aws_instances" "workers" {
  instance_tags = {
    Name = "react_calculator_asg"
  }
}