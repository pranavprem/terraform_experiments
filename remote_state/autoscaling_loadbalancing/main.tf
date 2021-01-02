provider "aws" {

}

terraform {
    backend "s3" {
        bucket = "react-calculator-remote-state"
        key = "global/s3/terraform-autoscaling-loadbalancing.tfstate"
        dynamodb_table = "react-calculator-locks"
        encrypt = true
    }
}

data "terraform_remote_state" "launch_config" {
    backend = "s3"
    config = {
        bucket = "react-calculator-remote-state"
        key = "global/s3/terraform-launch-config.tfstate"
    }
}