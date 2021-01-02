output "bucket_name" {
    value = aws_s3_bucket.terraform_state.id
    description = "S3 bucket name to be used for remote state store"
}

output "dynamo_name" {
    value = aws_dynamodb_table.terraform_locks.id
    description = "Dynamo table name to be used for remote state modification lock store"
}