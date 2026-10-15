# The 2020 config pinned ami-05ec0d2eeb9187f51, which no longer resolves.
# user-data uses apt, so look up the current Ubuntu 24.04 LTS image.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "react_calculator_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name                    = aws_key_pair.react_calculator_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.react_calculator_sg.id]
  user_data                   = file("${path.module}/../scripts/user-data.sh")
  user_data_replace_on_change = true

  tags = {
    Name = var.ec2_name
  }
}
