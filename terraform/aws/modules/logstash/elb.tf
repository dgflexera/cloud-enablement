resource "aws_elb" "logstash-elb" {
  name            = "logstash-${var.env}-elb"
  security_groups = ["${aws_security_group.logstash.id}"]
  subnets         = ["${split(",", var.subnets)}"]
  security_groups = ["${aws_security_group.logstash.id}"]
  internal        = true

  listener {
    instance_port     = 5500
    instance_protocol = "tcp"
    lb_port           = 5500
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:5500"
    interval            = 30
  }

  tags {
    env = "${var.env}"
    app = "logstash"
  }
}
