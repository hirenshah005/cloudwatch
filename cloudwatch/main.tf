data "aws_instances" "all_ec2" {
  instance_state_names = ["running", "stopped"]

  filter {
    name   = "vpc-id"
    values = ["${var.vpc_id}"]
  }
}

#-----------CPU Alarms----------------------------
resource "aws_cloudwatch_metric_alarm" "ec2-high-cpu" {
  count                     = "${length(data.aws_instances.all_ec2.ids)}"
  alarm_name                = "ec2-cpu-usage-above-85-${data.aws_instances.all_ec2.ids[count.index]}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  datapoints_to_alarm       = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  threshold                 = "85"
  insufficient_data_actions = []

  dimensions {
    InstanceId = "${element(data.aws_instances.all_ec2.ids, count.index)}"
  }

  alarm_description = "This alarm will trigger when CPU usage will go above 85% on --> ${data.aws_instances.all_ec2.ids[count.index]}"
  alarm_actions     = ["${var.sns_notification_arn}"]
}

data "aws_instance" "x" {
  count = "${length(data.aws_instances.all_ec2.ids)}"
}

#------------Disk Alarms------------------
resource "aws_cloudwatch_metric_alarm" "disk_used_percent" {
  count                     = "${length(data.aws_instance.x.ebs_block_device)}"
  alarm_name                = "Disk_used_percent_below_10%_on-${data.aws_instance.x.id}-${data.aws_instance.x.ebs_block_device[count.index].device_name}"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  datapoints_to_alarm       = "2"
  metric_name               = "disk_used_percent"
  namespace                 = "Custim/CWAgent"
  period                    = "900"
  threshold                 = "10"
  insufficient_data_actions = []

  dimensions {
    InstanceId = "${element(data.aws_instances.all_ec2.ids, count.index)}"
  }

  alarm_description = "This alarm will trigger when usable EBS storage is below 10% on --> ${data.aws_instances.all_ec2.ids[count.index]}"
  alarm_actions     = ["${var.sns_notification_arn}"]
}
