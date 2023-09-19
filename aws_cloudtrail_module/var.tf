variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for CloudTrail logs"
  type        = string
}

variable "cloudtrail_trail_name" {
  description = "The name of the new CloudTrail trail"
  type        = string
}

variable "cloudtrail_role_name" {
  description = "Name of the IAM role for CloudTrail"
  type        = string
}
