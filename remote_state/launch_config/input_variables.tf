variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "ssh_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 22
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

variable "key_pair_name" {
  description = "The name of the key pair for EC2"
  type        = string
  default     = "react_calculator_key_pair"
}

