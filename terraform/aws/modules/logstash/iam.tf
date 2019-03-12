resource "aws_iam_instance_profile" "logstash" {
  name_prefix = "logstash_${var.env}"
  role        = "${aws_iam_role.logstash.name}"
}

resource "aws_iam_role" "logstash" {
  name_prefix = "logstash_${var.env}"
  path        = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
