data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "private_subnet" {
  count             = "${var.subnet_count}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.selected.cidr_block, var.subnet_mask, var.subnet_offset + count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name    = "${var.env}-subnet-private-${count.index}"
    env     = "${var.env}"
    comment = "managed by terraform"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = "${var.subnet_count}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.selected.cidr_block, var.subnet_mask, var.subnet_count + var.subnet_offset + count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name    = "${var.env}-subnet-public-${count.index}"
    env     = "${var.env}"
    comment = "Managed by Terraform"
  }
}

resource "aws_route_table" "public" {
  count  = "${var.subnet_count}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name    = "public_subnet-${count.index}"
    env     = "${var.env}"
    comment = "Managed by Terraform"
  }
}

output "aws_route_table_public" {
  value = "${aws_route_table.public.*.id}"
}

resource "aws_route" "public" {
  route_table_id         = "${element(aws_route_table.public.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.vpc_gw.id}"
  count                  = "${var.subnet_count}"
}

output "public_route_table_ids" {
  value = "${aws_route_table.public.*.id}"
}

resource "aws_eip" "public_nat" {
  vpc   = true
  count = "${var.subnet_count}"

  tags {
    Name    = "eip-nat-${var.env}"
    env     = "${var.env}"
    Comment = "Managed by Terraform"
  }
}

resource "aws_nat_gateway" "private_gateway" {
  count         = "${var.subnet_count}"
  allocation_id = "${element(aws_eip.public_nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"
}

resource "aws_route" "private" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.private_gateway.*.id, count.index)}"
  count                  = "${var.subnet_count}"
}

output "private_route_table_ids" {
  value = "${aws_route_table.private.*.id}"
}

resource "aws_route_table" "private" {
  count  = "${var.subnet_count}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name    = "private_subnet-${count.index}"
    env     = "${var.env}"
    comment = "Managed by Terraform"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${var.subnet_count}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count          = "${var.subnet_count}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

output "private_subnets" {
  value = ["${aws_subnet.private_subnet.*.id}"]
}

output "public_subnets" {
  value = ["${aws_subnet.public_subnet.*.id}"]
}

output "outbound_ips" {
  value = ["${aws_eip.public_nat.*.public_ip}"]
}
