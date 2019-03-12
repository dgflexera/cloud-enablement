variable "es_endpoint" {
  default = ""
}
variable "es_enabled" {
  default = "true"
}
variable "log_group_name" {}

variable "env" {}
variable "private_subnets" {}
variable "cloudwatch_source_arn" {}
variable "elasticsearch_sg" {
  default = ""
}
