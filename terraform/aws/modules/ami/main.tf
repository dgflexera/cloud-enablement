data "aws_region" "current" {}

provider "aws" {
  alias = "source_ami"
  region = "${var.source_region}"
}

data "aws_ami" "ami" {
  provider = "aws.source_ami"
  most_recent = true
  owners           = ["self"]
  filter {
    name   = "tag:Name"
    values = ["${var.ami_name}"]
  }
  filter {
    name = "tag:env"
    values = ["${var.source_env}"]
}
}

resource "aws_ami_copy" "in_use" {
  name              = "${var.ami_name}"
  description       = "DO NOT DELETE"
  source_ami_id     = "${data.aws_ami.ami.id}"
  source_ami_region = "${var.source_region}"

  tags {
    Name       = "${var.ami_name}"
    env        = "${var.env}"
    source_ami = "${data.aws_ami.ami.name}"
  }
}

output "ami_id" {
  value = "${aws_ami_copy.in_use.id}"
}
