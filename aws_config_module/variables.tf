variable "bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
}

variable "sns_topic_name" {
  description = "Name for the SNS topic"
  type        = string
}

variable "delivery_channel_name" {
  description = "Name for the AWS Config delivery channel"
  type        = string
}

variable "config_rule_name" {
  description = "Name for the AWS Config Rule"
  type        = string
}
