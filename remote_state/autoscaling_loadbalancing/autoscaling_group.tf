resource "aws_autoscaling_group" "react_calculator_asg" {
  launch_configuration = data.terraform_remote_state.launch_config.outputs.launch_config_name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 10

  target_group_arns = [aws_lb_target_group.asg.arn]

  tag {
    key                 = "Name"
    value               = "react_calculator_asg"
    propagate_at_launch = true
  }
}