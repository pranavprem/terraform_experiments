variable "aws_region" {
  description = "AWS region for this stack. Keep it aligned with backend.hcl."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type. The 2020 config used t2.micro."
  type        = string
  default     = "t2.micro"
}

variable "server_port" {
  description = "Port the calculator listens on. webpack-dev-server defaults to 8080."
  type        = number
  default     = 8080
}

variable "ssh_port" {
  description = "Port opened for SSH."
  type        = number
  default     = 22
}

variable "security_group_name" {
  description = "Name of the instance security group."
  type        = string
  default     = "react_calculator_sg"
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair."
  type        = string
  default     = "react_calculator_key_pair"
}
