Searches current AWS account and region for AMIs matching tags
Usage:
```
module "logstash_ami" {
  source   = "github.com/flexera/cloud-enablement/terraform/aws/modules/ami"
  ami_name = "logstash"
  source_region = "${var.region}"
  env      = "${var.env}"
}

module "logstash" {
  source            = "github.com/flexera/cloud-enablement/terraform/aws/modules/logstash"
  ami_id            = "${module.logstash_ami.ami_id}"
  es_endpoint       = "${module.elasticsearch.es_endpoint}"
  es_security_group_id = "${module.elasticsearch.security_group}"
  subnets           = "${join(",", module.vpc.private_subnets)}"
  vpc_id            = "${module.vpc.vpc_id}"
  env               = "${var.env}"
  es_retention_days = "${var.es_retention_days}"
  min_instances     = "${var.logstash_min_instances}"
  desired_capacity  = "${var.logstash_min_instances}"
}
