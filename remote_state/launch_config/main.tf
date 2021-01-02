provider "aws" {

}

terraform {
    backend "s3" {
        bucket = "react-calculator-remote-state"
        key = "global/s3/terraform-launch-config.tfstate"
        dynamodb_table = "react-calculator-locks"
        encrypt = true
    }
}