Forwards cloudwatch log group events to elasticsearch using lambda function

Usage:
```
resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = "vpc-flow-${var.env}"
  retention_in_days = 1
}
module "cloudwatch_lambda" {
  source                = "github.com/flexera/cloud-enablement/terraform/aws/modules/cloudwatch_lambda"
  es_endpoint           = "${var.es_endpoint}"
  env                   = "${var.env}"
  log_group_name        = "${aws_cloudwatch_log_group.vpc_flow_log.name}"
  private_subnets       = "${join(",", aws_subnet.private_subnet.*.id)}"
  cloudwatch_source_arn = "${aws_cloudwatch_log_group.vpc_flow_log.arn}"
  elasticsearch_sg      = "${var.elasticsearch_sg}"
  es_enabled = "${var.es_flow_enabled}"
}
