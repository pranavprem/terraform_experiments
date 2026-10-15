output "bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "S3 bucket name used for remote state."
}

output "dynamo_name" {
  value       = aws_dynamodb_table.terraform_locks.id
  description = "DynamoDB table name used for state locks."
}
