resource "aws_config_configuration_recorder" "detective_controls" {
  role_arn = aws_iam_role.aws_config_role.arn
  name     = "detective-controls"
  recording_group {
    all_supported  = false
    resource_types = ["AWS::S3::Bucket", "AWS::S3::AccountPublicAccessBlock"]
  }
}

resource "aws_config_configuration_recorder_status" "detective_controls" {
  is_enabled = true
  name       = aws_config_configuration_recorder.detective_controls.name
  depends_on = [aws_config_delivery_channel.detective_controls]
}

data "aws_iam_policy_document" "aws_config_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "aws_config_role" {
  assume_role_policy = data.aws_iam_policy_document.aws_config_role.json
  name               = "my-awsconfig-role"

}

data "aws_iam_policy_document" "aws_config_role_policy" {
  statement {
    effect = "Allow"
    actions = ["config:BatchGet*", "config:Describe*", "config:Get*", "config:List*", "config:Put*", "config:Select*",
    "s3:Get*", "s3:List*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:CreateLogGroup"]
    resources = ["arn:aws:logs:*:*:log-group:/aws/config/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:log-group:/aws/config/*:log-stream:config-rule-evaluation/*"]
  }

}

resource "aws_iam_role_policy" "aws_config_role" {
  policy = data.aws_iam_policy_document.aws_config_role_policy.json
  role   = aws_iam_role.aws_config_role.id
  name   = "my-awsconfig-policy"

}
resource "aws_s3_bucket" "controls_storage" {
  bucket        = var.bucket_name
  force_destroy = true
}

data "aws_iam_policy_document" "controls_storage" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetBucketAcl", "s3:GetBucketPolicy"]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    resources = [aws_s3_bucket.controls_storage.arn]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:PutObject", "s3:PutObjectAcl"]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    resources = ["${aws_s3_bucket.controls_storage.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "controls_storage" {
  bucket = aws_s3_bucket.controls_storage.id
  policy = data.aws_iam_policy_document.controls_storage.json
}

resource "aws_sns_topic" "control_send" {
  name = var.sns_topic_name
}

resource "aws_config_delivery_channel" "detective_controls" {
  s3_bucket_name = aws_s3_bucket.controls_storage.bucket
  sns_topic_arn  = aws_sns_topic.control_send.arn
  name           = var.delivery_channel_name

  snapshot_delivery_properties {
    delivery_frequency = "Six_Hours"
  }

  depends_on = [
    aws_s3_bucket.controls_storage,
    aws_sns_topic.control_send,
    aws_config_configuration_recorder.detective_controls,
  ]

}

resource "aws_config_config_rule" "s3_versioning_enabled" {
  name = var.config_rule_name
  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }
  depends_on = [aws_config_configuration_recorder.detective_controls]
}
