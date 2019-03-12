data "aws_caller_identity" "current" {}

data "aws_region" "current" {
}

resource "aws_lambda_function" "cwl_stream_lambda" {
  filename         = "${path.module}/cwl2eslambda.zip"
  function_name    = "cw2es${replace(var.log_group_name,"/","_")}"
  role             = "${aws_iam_role.lambda_elasticsearch_execution_role.arn}"
  handler          = "cwl2es.handler"
  source_code_hash = "${base64sha256(file("${path.module}/cwl2eslambda.zip"))}"
  runtime          = "nodejs4.3"
  vpc_config = {
    security_group_ids = ["${var.elasticsearch_sg}"]
    subnet_ids  = ["${split(",", var.private_subnets)}"]
  }
  environment {
    variables = {
      endpoint = "${var.es_endpoint}"
    }
  }
  count = "${var.es_enabled == "true" ? 1: 0}"
  depends_on = ["aws_cloudwatch_log_group.cw_lambda"]
}

resource "aws_cloudwatch_log_group" "cw_lambda" {
  name = "/aws/lambda/cw2es${replace(var.log_group_name,"/","_")}"
  retention_in_days = 1
  tags {
    app = "cloudwatch_lambda"
    env = "${var.env}"
  }
}

resource "aws_lambda_permission" "cloudwatch_allow" {
  statement_id = "cloudwatch_allow"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cwl_stream_lambda.function_name}"
  principal = "logs.amazonaws.com"
  source_arn = "${var.cloudwatch_source_arn}"
  count = "${var.es_enabled == "true" ? 1: 0}"
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_logs_to_es" {
  name = "cw_to_es_${var.env}"
  log_group_name = "${var.log_group_name}"
  filter_pattern = ""
  destination_arn = "${aws_lambda_function.cwl_stream_lambda.arn}"
  count = "${var.es_enabled == "true" ? 1: 0}"
}

#output "lambda_name" {
#  value = "${aws_lambda_function.cwl_stream_lambda.function_name}"
#}
#
#output "iam_lambda_arn" {
#  value = "${aws_iam_role.lambda_elasticsearch_execution_role.arn}"
#}
