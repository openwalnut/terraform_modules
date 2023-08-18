output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.controls_storage.id
}

output "sns_topic_name" {
  description = "Name of the created SNS topic"
  value       = aws_sns_topic.control_send.name
}

output "delivery_channel_name" {
  description = "Name of the created AWS Config delivery channel"
  value       = aws_config_delivery_channel.detective_controls.name
}

output "config_rule_name" {
  description = "Name of the created AWS Config rule"
  value       = aws_config_config_rule.s3_versioning_enabled.name
}
