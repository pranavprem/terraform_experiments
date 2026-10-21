resource "aws_autoscaling_group" "react_calculator_asg" {
  name                = "react-calculator"
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size                  = 2
  max_size                  = 10
  health_check_type         = "ELB"
  health_check_grace_period = 600

  launch_template {
    id      = data.terraform_remote_state.launch_config.outputs.launch_template_id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.asg.arn]

  tag {
    key                 = "Name"
    value               = "react_calculator_asg"
    propagate_at_launch = true
  }
}

data "aws_instances" "workers" {
  depends_on           = [aws_autoscaling_group.react_calculator_asg]
  instance_state_names = ["pending", "running"]

  instance_tags = {
    Name = "react_calculator_asg"
  }
}
