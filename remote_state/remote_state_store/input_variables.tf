variable "bucket_name" {
    description = "Name of S3 bucket that will store state"
    default = "react-calculator-remote-state"
    type = string
}

variable "dynamo_db_name" {
    description = "Name of Dynamo DB that will store state modification locks"
    default = "react-calculator-locks"
    type = string
}