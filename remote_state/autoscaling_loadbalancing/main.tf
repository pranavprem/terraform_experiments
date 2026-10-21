provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "launch_config" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.launch_config_state_key
    region = var.aws_region
  }
}
