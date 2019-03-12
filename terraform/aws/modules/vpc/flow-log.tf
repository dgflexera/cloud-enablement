resource "aws_flow_log" "vpc_flow_log" {
  log_destination = "${aws_cloudwatch_log_group.vpc_flow_log.arn}"
  iam_role_arn   = "${aws_iam_role.vpc_flow.arn}"
  vpc_id         = "${aws_vpc.main.id}"
  traffic_type   = "ALL"
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = "vpc-flow-${var.env}"
  retention_in_days = 1
}

resource "aws_iam_role" "vpc_flow" {
  name = "vpc_flow_${var.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow" {
  name = "vpc_flow_${var.env}"
  role = "${aws_iam_role.vpc_flow.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

module "cloudwatch_lambda" {
  source                = "../cloudwatch_lambda"
  es_endpoint           = "${var.es_endpoint}"
  env                   = "${var.env}"
  log_group_name        = "${aws_cloudwatch_log_group.vpc_flow_log.name}"
  private_subnets       = "${join(",", aws_subnet.private_subnet.*.id)}"
  cloudwatch_source_arn = "${aws_cloudwatch_log_group.vpc_flow_log.arn}"
  elasticsearch_sg      = "${var.elasticsearch_sg}"
  es_enabled = "${var.es_flow_enabled}"
}
