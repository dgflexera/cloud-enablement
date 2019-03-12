variable "env" {}

variable "app" {}

variable "artifact_etag" {}

variable "ami_id" {}

variable "instance_type" {}

variable "iam_profile_name" {}

variable "security_group_ids" {}

variable "rendered_template_file" {}

variable "volume_size" {}

variable "subnet_ids" {}

variable "max_instances" {}

variable "min_instances" {}

variable "batch_size" {
  default = 1
}

variable "pause_time_minutes" {
  default = 5
}

variable "autoscale_cooldown" {
  default = 300
}

variable "asg_metric" {
  default = "ASGAverageCPUUtilization"
}

variable "asg_target" {
  default = 40
}

variable "elb_name" {}

variable "healthcheck_grace_period" {
  default = 600
}
