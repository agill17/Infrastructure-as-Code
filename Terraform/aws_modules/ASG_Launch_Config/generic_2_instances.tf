

resource "aws_launch_configuration" "lg" {
  name            = "${var.env}-${var.lg_name}"
  image_id        = "${var.lg_image_id}"
  instance_type   = "${var.lg_instance_type}"
  key_name        = "${var.lg_key_name}"
  security_groups = "${var.lg_security_group_ids}"

  tags = {
    Name = "${var.env}-${var.lg_name}"
  }
}

resource "aws_autoscaling_group" "asg" {
  depends_on                = ["aws_launch_configuration.lg"]
  name                      = "${var.env}-${var.asg_name}"
  launch_configuration      = "${aws_launch_configuration.lg.name}"
  min_size                  = "${var.asg_min_instances}"
  max_size                  = "${var.asg_max_instances}"
  default_cooldown          = "${var.asg_default_cooldown}"
  health_check_grace_period = "${var.asg_health_check_grace_period}"
  health_check_type         = "${var.asg_health_check_type}"
  vpc_zone_identifier       = "${var.asg_subnet_ids}"
}

## TODO


## Add some attribute outputs from lg and asg

