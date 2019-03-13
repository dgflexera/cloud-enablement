VPC Elasticsearch cluster for logging with LAMBDA functions for curating old logs

Usage:
```
module "elasticsearch" {
  source     = "github.com/flexera/cloud-enablement/terraform/aws/modules/elasticsearch"
  private_subnets = "${join(",", module.vpc.private_subnets)}"
  count      = "${var.es_instance_count}"
  type = "${var.es_instance_type}"
  size       = "${var.es_instance_size}" # EBS in GB
  env        = "${var.env}"
  vpc_id = "${module.vpc.vpc_id}"
}
