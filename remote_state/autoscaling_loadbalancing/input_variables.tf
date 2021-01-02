
variable "alb_name" {
  description = "The name of the ALB"
  type        = string
  default     = "react-calculator-asg"
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type        = string
  default     = "react_calculator_alb"
}