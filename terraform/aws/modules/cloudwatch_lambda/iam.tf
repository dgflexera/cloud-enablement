resource "aws_iam_role" "lambda_elasticsearch_execution_role" {
  name = "es_${replace(var.log_group_name,"/","_")}-${var.env}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  count = "${var.es_enabled == "true" ? 1: 0}"
}

resource "aws_iam_role_policy" "lambda_elasticsearch_execution_policy" {
  name = "lambda_elasticsearch_execution_policy_${var.env}"
  role = "${aws_iam_role.lambda_elasticsearch_execution_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
	"ec2:createNetworkInterface",
	"ec2:DescribeNetworkInterfaces",
	"ec2:DeleteNetworkInterface"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "es:ESHttpPost",
      "Resource": "arn:aws:es:*:*:*"
    }
  ]
}
EOF
  count = "${var.es_enabled == "true" ? 1: 0}"
}
