variable "ami_id" {}

variable "es_endpoint" {}

variable "env" {}

variable "subnets" {}

variable "vpc_id" {}

variable "version" {
  default = "logstash-6.2.2"
}

variable "type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}

variable "datadog_enabled" {
  default = "true"
}

variable "es_retention_days" {
  default = 14
}

variable "min_instances" {
  default = 2
}

variable "max_instances" {
  default = 4
}

variable "volume_size" {
  default = 10
}
variable "es_security_group_id" {}
