output "alb_dns_name" {
  value       = aws_lb.react_calculator_lb.dns_name
  description = "The domain name of the load balancer"
}

// output "public_ips" {
//   value = data.aws_instances.workers.public_ips
// }

// data "aws_instances" "workers" {
//   instance_tags = {
//     Name = "react_calculator_asg"
//   }
// }