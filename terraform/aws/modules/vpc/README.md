Create Private VPC



Usage:
```
vpc_cidr="10.0.0.0/20"
subnet_count="2"
# Resulting should be vpc_cidr + subnet_mask
subnet_mask="4"
subnet_offset="1"

module "vpc" {
  source                  = "github.com/flexera/cloud-enablement/terraform/aws/modules/vpc"
  env                     = "${var.env}"
  subnet_count            = "${var.subnet_count}"
  subnet_mask             = "${var.subnet_mask}"
  subnet_offset           = "${var.subnet_offset}"
  vpc_cidr                = "${var.vpc_cidr}"
  es_flow_enabled         = "false"
}
