output "s3_bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = aws_s3_bucket.cloudtrail.arn
}

output "cloudtrail_role_arn" {
  description = "The ARN of the IAM role for CloudTrail"
  value       = aws_iam_role.cloudtrail_role.arn
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch Log Group for CloudTrail logs"
  value       = aws_cloudwatch_log_group.cloudtrail_logs.arn
}

output "cloudtrail_name" {
  description = "The name of the created CloudTrail trail"
  value       = aws_cloudtrail.maangement_events.name
}
