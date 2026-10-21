variable "aws_region" {
  description = "AWS region for this stack. Keep it aligned with backend.hcl."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket that will store Terraform state. Must be globally unique. The default is the name from the 2021 experiment."
  type        = string
  default     = "react-calculator-remote-state"
}

variable "dynamo_db_name" {
  description = "DynamoDB table that stores state locks."
  type        = string
  default     = "react-calculator-locks"
}
