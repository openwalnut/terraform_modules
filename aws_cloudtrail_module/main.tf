#Create KMS key for Cloudtrail logs encryption

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudtrail_key" {
  statement {
    sid    = "Enable Owner & Root full access to KMS key"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:us-east-1:${data.aws_caller_identity.current.account_id}:trail/*"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:us-east-1:${data.aws_caller_identity.current.account_id}:trail/*"]
    }

  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to decrypt a trail"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:CreateAlias",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.us-east-1.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

  }

}

resource "aws_kms_key" "cloudtrail_key" {
  description             = "KMS key for CloudTrail logs encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudtrail_key.json
}

resource "aws_kms_alias" "cloudtrail_key" {
  target_key_id = aws_kms_key.cloudtrail_key.key_id
  name          = "alias/cloudtrail"

}

#Create S3 bucket

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.cloudtrail_key.arn
    }
  }

}

data "aws_iam_policy_document" "cloudtrail" {

  statement {
    sid    = "AWS CloudTrail ACL Check"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:us-east-1:${data.aws_caller_identity.current.account_id}:trail/${var.cloudtrail_trail_name}"]
    }

  }

  statement {
    sid    = "AWS CloudTrail Write"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:us-east-1:${data.aws_caller_identity.current.account_id}:trail/${var.cloudtrail_trail_name}"]
    }
  }

}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail.json

}


#Create IAM role for cloudtrail to send logs to Cloudwatch

resource "aws_iam_role" "cloudtrail_role" {
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_role.json
  name               = var.cloudtrail_role_name
}

data "aws_iam_policy_document" "cloudtrail_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudtrail_role_policy" {

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream"]
    resources = ["arn:aws:logs:*:*:log-group:${var.cloudwatch_log_group_name}:log-stream:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:log-group:${var.cloudwatch_log_group_name}:log-stream:*"]
  }

}

resource "aws_iam_role_policy" "cloudtrail_role" {
  policy = data.aws_iam_policy_document.cloudtrail_role_policy.json
  role   = aws_iam_role.cloudtrail_role.id
  name   = "my-cloudtrail-policy"

}

#Create CloudWatch Logs group

resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = 365
}

#Create CloudTrail trail

resource "aws_cloudtrail" "maangement_events" {
  name                       = var.cloudtrail_trail_name
  s3_bucket_name             = aws_s3_bucket.cloudtrail.id
  s3_key_prefix              = "cloudtrail-logs"
  is_multi_region_trail      = false
  enable_logging             = true
  enable_log_file_validation = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_logs.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_role.arn

  kms_key_id = aws_kms_key.cloudtrail_key.arn

  #Define management events

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${aws_s3_bucket.cloudtrail.id}/cloudtrail-logs/*"]
    }
  }

}
