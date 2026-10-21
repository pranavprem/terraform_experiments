# Terraform's S3 backend expects the lock item's hash key to be named LockID.
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamo_db_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
