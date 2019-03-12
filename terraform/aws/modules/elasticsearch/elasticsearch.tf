data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_elasticsearch_domain_policy" "es-logs" {
  domain_name = "${aws_elasticsearch_domain.es-logs.domain_name}"

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "${aws_elasticsearch_domain.es-logs.arn}/*"
      }
  ]
}
POLICIES
}


resource "aws_security_group" "elasticsearch" {
  name = "elasticsearch-${var.domain}-${var.env}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true" 
  }
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "elasticsearch-${var.env}"
    env = "${var.env}"
  }
}

output "security_group" {
  value = "${aws_security_group.elasticsearch.id}"
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"

}

resource "aws_elasticsearch_domain" "es-logs" {
  domain_name           = "${var.domain}-${var.env}"
  elasticsearch_version = "${var.version}"

  cluster_config {
    instance_type          = "${var.type}"
    instance_count         = "${var.count}"
    zone_awareness_enabled = "${var.count == "1" ? "false" : "true"}"
  }

  ebs_options {
    ebs_enabled = "true"
    volume_type = "${var.volume_type}"
    volume_size = "${var.size}"
  }
  encrypt_at_rest = {
    enabled = "true"
  }
  node_to_node_encryption = {
    enabled = "true"
  }
  vpc_options {
    security_group_ids = ["${list(aws_security_group.elasticsearch.id, aws_security_group.lambda.id)}"]
    subnet_ids = ["${slice(split(",", var.private_subnets),0,var.count == "1" ? 1 : 2)}"]
  }
  snapshot_options {
    automated_snapshot_start_hour = "${var.snapshot_time}"
  }

  tags {
    Domain = "${var.domain}"
    env    = "${var.env}"
  }
  depends_on = [
      "aws_iam_service_linked_role.es"
  ]
}

output "es_endpoint" {
  value = "${aws_elasticsearch_domain.es-logs.endpoint}"
}
