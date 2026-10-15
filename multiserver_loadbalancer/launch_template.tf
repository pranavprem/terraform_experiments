# The 2020 config pinned ami-05ec0d2eeb9187f51, which no longer resolves.
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

# Accounts created on or after 2024-10-01 cannot create EC2 launch configurations.
# The autoscaling group still launches the same calculator instances from this template.
resource "aws_launch_template" "react_calculator" {
  name          = "react-calculator"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.react_calculator_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.react_calculator_sg.id]
  user_data              = base64encode(file("${path.module}/../scripts/user-data.sh"))
}
