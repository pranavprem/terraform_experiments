resource "aws_instance" "first_ec2" {
  instance_type = "t2.micro"
  ami           = "ami-0c55b159cbfafe1f0"
  tags = {
    Name = "pranavs_first_terraform_ec2"
  }
}