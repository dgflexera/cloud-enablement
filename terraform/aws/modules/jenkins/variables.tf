variable "env" {}

variable "ami_id" {}

variable "subnets" {}

variable "vpc_id" {}
variable "cert_arn" {
  default = ""
}
variable "type" {
  default = "t3.micro"
}

variable "desired_capacity" {
  default = 1
}

variable "volume_size" {
  default = 10
}
variable "elb_internal" {
  default = false
}
variable "elb_subnets" {}
variable "jenkins_domain" {}
variable "allowed_ips" {
  default = "0.0.0.0/0"
}
