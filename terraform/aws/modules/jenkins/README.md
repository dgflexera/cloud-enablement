Self-healing EFS-backed jenkins instance for deployment into a VPC

Inspect system log on AWS console for the initial password once instance is online.

Usage:
```
module "jenkins" {
  source  = "github.com/flexera/cloud-enablement/terraform/aws/modules/jenkins"
  ami_id  = "${module.jenkins_ami.ami_id}"
  subnets = "${join(",", module.vpc.private_subnets)}"
  vpc_id  = "${module.vpc.vpc_id}"
  type           = "t3.xlarge"
  env            = "${var.env}"
  elb_internal   = true
  elb_subnets    = "${join(",", module.vpc.private_subnets)}"
  jenkins_domain = "${aws_route53_record.jenkins.name}"
  allowed_ips    = "0.0.0.0/0"
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${aws_route53_zone.env.zone_id}"
  name    = "jenkins.${aws_route53_zone.env.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.jenkins.jenkins_endpoint}"]
}
