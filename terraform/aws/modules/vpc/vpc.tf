resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"

  tags {
    Name    = "${var.env}"
    env     = "${var.env}"
    comment = "Managed by Terraform"
  }
}

resource "aws_internet_gateway" "vpc_gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.env}-igw"
    env  = "${var.env}"
  }
}
