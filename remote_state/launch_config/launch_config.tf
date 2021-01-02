resource "aws_launch_configuration" "react_calculator_launch_config" {
  instance_type = "t2.micro"
  image_id      = "ami-05ec0d2eeb9187f51"
  
  key_name       = aws_key_pair.react_calculator_key_pair.id
  security_groups = [aws_security_group.react_calculator_sg.id]
  user_data      = data.template_file.user_data.rendered

}
