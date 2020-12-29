resource "aws_instance" "react_calculator_ec2" {
  instance_type = "t2.micro"
  ami           = "ami-05ec0d2eeb9187f51"
  tags = {
    Name = var.ec2_name
  }
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = <<-EOF
              #!/bin/bash
              git clone https://github.com/pranavprem/ReactCalculator
              cd ReactCalculator
              npm install
              npm run dev
              EOF

}

resource "aws_security_group" "instance" {

  name = var.security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}