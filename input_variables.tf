variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "react_calculator_sg"
}

variable "ec2_name" {
  description = "The name of the ec2 instance"
  type        = string
  default     = "react_calculator"
}