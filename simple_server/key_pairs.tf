resource "aws_key_pair" "react_calculator_key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.react_calculator_public_key.public_key_openssh
}


resource "tls_private_key" "react_calculator_public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}