#------root/main.tf

provider "aws" {
  profile = "${var.profile_name}"
  region  = "${var.region}"
}

module "cloudwatch-metrics" {
  source               = "./cloudwatch"
  vpc_id               = "${var.vpc_id}"
  sns_notification_arn = "${var.sns_notification_arn}"
}
