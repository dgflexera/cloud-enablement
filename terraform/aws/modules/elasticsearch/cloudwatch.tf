resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "es-cleanup-execution-schedule-${var.env}"
  description         = "es-cleanup execution schedule-${var.env}"
  schedule_expression = "${var.schedule}"
  count = "${var.cleanup_enabled == "true" ? 1 : 0}"
}

resource "aws_cloudwatch_event_target" "es_cleanup_vpc" {
  target_id = "lambda-es-cleanup-${var.env}"
  rule      = "${aws_cloudwatch_event_rule.schedule.name}"
  arn       = "${aws_lambda_function.es_cleanup_vpc.arn}"
  count = "${var.cleanup_enabled == "true" ? 1 : 0}"
}

resource "aws_lambda_permission" "allow_cloudwatch_vpc" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.es_cleanup_vpc.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.schedule.arn}"
  count = "${var.cleanup_enabled == "true" ? 1 : 0}"
}
