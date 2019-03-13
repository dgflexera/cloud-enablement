data "template_file" "logstash" {
  template = "${file("${path.module}/provisioning/logstash.tpl")}"

  vars {
    es_endpoint      = "${var.es_endpoint}"
    logstash_version = "${var.version}"
    es_retention     = "${var.es_retention_days}"
    datadog_enabled  = "${var.datadog_enabled}"
  }
}

module "ec2_autoscaling" {
  source                 = "github.com/flexera/cloud-enablement/terraform/aws/modules/ec2_autoscaling"
  env                    = "${var.env}"
  app                    = "logstash"
  artifact_etag          = "${var.ami_id}"
  ami_id                 = "${var.ami_id}"
  instance_type          = "${var.type}"
  iam_profile_name       = "${aws_iam_instance_profile.logstash.name}"
  security_group_ids     = "${aws_security_group.logstash.id},${var.es_security_group_id}"
  rendered_template_file = "${data.template_file.logstash.rendered}"
  volume_size            = "${var.volume_size}"
  subnet_ids             = "${var.subnets}"
  max_instances          = "${var.max_instances}"
  min_instances          = "${var.min_instances}"
  elb_name               = "${aws_elb.logstash-elb.name}"
}

output "logstash_endpoint" {
  value = "${aws_elb.logstash-elb.dns_name}"
}
