#------root/main.tf

provider "aws" {
  profile = "${var.profile_name}"
  region  = "${var.region}"
}

data "aws_instances" "all_ec2" {
  instance_state_names = ["running", "stopped"]

  filter {
    name   = "vpc-id"
    values = ["${var.vpc_id}"]
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2-high-cpu" {
  count               = "${length(data.aws_instances.all_ec2.ids)}"
  alarm_name          = "ec2-cpu-usage-above-75-${data.aws_instances.all_ec2.ids[count.index]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  threshold           = "75"
}
