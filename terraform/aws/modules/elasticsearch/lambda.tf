data "archive_file" "es_cleanup_lambda" {
  type        = "zip"
  source_file = "${path.module}/es-cleanup.py"
  output_path = "${path.module}/es-cleanup.zip"
}

resource "aws_lambda_function" "es_cleanup_vpc" {
  filename         = "${path.module}/es-cleanup.zip"
  function_name    = "es-cleanup-${var.domain}-${var.env}"
  description      = "es-cleanup-${var.domain}-${var.env}"
  timeout          = 300
  runtime          = "python${var.python_version}"
  role             = "${aws_iam_role.role.arn}"
  handler          = "es-cleanup.lambda_handler"
  source_code_hash = "${data.archive_file.es_cleanup_lambda.output_base64sha256}"

  environment {
    variables = {
      es_endpoint  = "${aws_elasticsearch_domain.es-logs.endpoint}"
      index        = "${var.index}"
      delete_after = "${var.delete_after}"
      index_format = "${var.index_format}"
      sns_alert    = "${var.sns_alert}"
    }
  }

  tags {
    Name = "es-cleanup"
    env = "${var.env}"
  }

  vpc_config {
    subnet_ids         = ["${slice(split(",", var.private_subnets),0,2)}"] 
    security_group_ids = ["${aws_security_group.lambda.*.id}"]
  }
  count = "${var.cleanup_enabled == "true" ? 1 : 0}"
}
