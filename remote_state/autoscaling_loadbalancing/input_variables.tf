variable "aws_region" {
  description = "AWS region for this stack. Keep it aligned with backend.hcl and the launch_config stack."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket" {
  description = "S3 bucket that holds the launch_config stack's state. Same bucket remote_state_store creates."
  type        = string
  default     = "react-calculator-remote-state"
}

variable "launch_config_state_key" {
  description = "State object key written by remote_state/launch_config."
  type        = string
  default     = "global/s3/terraform-launch-config.tfstate"
}

variable "alb_name" {
  description = "Name of the ALB and its target group."
  type        = string
  default     = "react-calculator-asg"
}

variable "alb_security_group_name" {
  description = "Name of the security group for the ALB."
  type        = string
  default     = "react_calculator_alb"
}
