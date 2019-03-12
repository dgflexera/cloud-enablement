output "security_group" {
  value = "${aws_security_group.logstash.id}"
}

resource "aws_security_group" "logstash" {
  name        = "logstash-${var.env}"
  vpc_id      = "${var.vpc_id}"
  description = "allow inbound to logstash"

  ingress {
    from_port   = 5500
    to_port     = 5500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5500
    to_port = 5500
    protocol = "tcp"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "logstash-${var.env}"
    app  = "logstash"
    env  = "${var.env}"
  }
}
