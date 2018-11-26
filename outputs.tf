output "instance_ids" {
  value = "${data.aws_instances.all_ec2.ids}"
}
