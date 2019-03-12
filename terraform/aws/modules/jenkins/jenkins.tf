resource "aws_security_group" "jenkins" {
  name        = "jenkins-${var.env}"
  vpc_id      = "${var.vpc_id}"
  description = "allow inbound to jenkins"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "jenkins-${var.env}"
    env = "${var.env}"
  }
}

resource "aws_security_group" "jenkins_elb" {
  name        = "jenkins-${var.env}-elb"
  vpc_id      = "${var.vpc_id}"
  description = "allow inbound to jenkins"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ips}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ips}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins-elb-${var.env}"
    env = "${var.env}"
  }
}

resource "aws_elb" "jenkins-elb" {
  name     = "jenkins-${var.env}-elb"
  subnets  = ["${split(",", var.elb_subnets)}"]
  internal = "${var.elb_internal}"
  security_groups = ["${aws_security_group.jenkins.id}","${aws_security_group.jenkins_elb.id}"]
  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/login"
    interval            = 30
  }

  tags {
    env = "${terraform.env}"
    app = "jenkins"
  }
}

data "template_file" "jenkins" {
  template = "${file("${path.module}/provisioning/jenkins.tpl")}"

  vars {
    EFS_ID = "${aws_efs_file_system.jenkins.id}"
    jenkins_domain = "${var.jenkins_domain}"
  }
}

resource "aws_efs_file_system" "jenkins" {
  performance_mode = "maxIO"
  encrypted = "true"
  tags {
    Name = "Jenkins filesystem"
    env = "${var.env}"
  }
}

resource "aws_efs_mount_target" "jenkins" {
  file_system_id = "${aws_efs_file_system.jenkins.id}"
  count          = "${length(split(",", var.subnets))}"
  subnet_id      = "${element(split(",", var.subnets), count.index)}"
  security_groups = ["${aws_security_group.jenkins.id}"]
  depends_on     = ["aws_efs_file_system.jenkins"]
}

resource "aws_launch_configuration" "jenkins" {
  name_prefix                 = "jenkins_${terraform.env}_"
  associate_public_ip_address = false
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.type}"
  security_groups             = ["${aws_security_group.jenkins.id}"]
  user_data                   = "${data.template_file.jenkins.rendered}"

  root_block_device = {
    delete_on_termination = true
    volume_size           = "${var.volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins_${var.env}"
  role = "${aws_iam_role.jenkins.name}"
}

resource "aws_iam_role" "jenkins" {
  name = "jenkins_${var.env}"
  path = "/"

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

resource "aws_iam_role_policy" "jenkins" {
  name = "jenkins_${var.env}"
  role = "${aws_iam_role.jenkins.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*",
	"ecr:*",
	"s3:*",
	"cloudfront:*",
        "iam:*",
        "kms:*",
        "ecs:*",
        "dynamodb:*",
	"autoscaling:*",
	"cloudformation:*",
	"route53:*",
	"elasticfilesystem:*",
	"acm:*",
	"elasticloadbalancing:*",
	"es:*",
	"rds:*",
	"cloudwatch:*",
	"logs:*",
	"lambda:*",
	"SNS:*",
	"application-autoscaling:*",
	"events:*",
	"sqs:*",
	"elasticache:*",
	"secretsmanager:*",
        "transfer:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

module "ec2_autoscaling" {
  source                 = "../ec2_autoscaling/"
  env                    = "${var.env}"
  app                    = "jenkins"
  artifact_etag          = "${var.ami_id}"
  ami_id                 = "${var.ami_id}"
  instance_type          = "${var.type}"
  iam_profile_name       = "${aws_iam_instance_profile.jenkins.name}"
  security_group_ids     = "${aws_security_group.jenkins.id}"
  rendered_template_file = "${data.template_file.jenkins.rendered}"
  volume_size            = "${var.volume_size}"
  subnet_ids             = "${var.subnets}"
  max_instances          = "2"
  min_instances          = "1"
  elb_name               = "${aws_elb.jenkins-elb.name}"
  asg_target             = "200"
}

output "jenkins_endpoint" {
  value = "${aws_elb.jenkins-elb.dns_name}"
}
