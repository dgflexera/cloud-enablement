variable "domain" {
  default = "es-logs"
}

variable "env" {}
variable "vpc_id" {}
variable "private_subnets" {}
variable "log_retention_days" {
  default = 30
}
variable "schedule" {
  default = "cron(0 3 * * ? *)"
}

variable "sns_alert" {
  description = "SNS ARN to pusblish any alert"
  default     = ""
}
variable "index" {
  description = "Index/indices to process comma separated, with all every index will be processed except '.kibana'"
  default     = "all"
}
variable "delete_after" {
  description = "Numbers of days to preserve"
  default     = 30
}

variable "index_format" {
  description = "Combined with 'index' varible is used to evaluate the index age"
  default     = "%Y.%m.%d"
}
variable "python_version" {
  default = "2.7"
}
variable "type" {
  default = "c4.large.elasticsearch"
}

variable "version" {
  default = "6.4"
}

variable "count" {
  default = "4"
}

variable "size" {
  default = "35"
}

variable "volume_type" {
  default = "standard"
}

variable "snapshot_time" {
  default = "23"
}

variable "za_enabled" {
  default = "true"
}
variable "cleanup_enabled" {
  default = "true"
}
