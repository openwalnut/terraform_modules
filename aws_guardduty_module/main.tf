data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "guardduty_bucket" {
  statement {
    sid = "Allow PutObject"
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.guardduty.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow GetBucketLocation"
    actions = [
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.guardduty.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket" "guardduty" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "gd_bucket_policy" {
  bucket = aws_s3_bucket.guardduty.id
  policy = data.aws_iam_policy_document.guardduty_bucket.json
}

data "aws_iam_policy_document" "guardduty_kms" {
  statement {
    sid = "Allow GuardDuty to encrypt findings"
    actions = [
      "kms:GenerateDataKey"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow root user to modify/delete key"
    actions = [
      "kms:*"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "guardduty_key" {
  description             = "Encryption key for Guardduty findings"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.guardduty_kms.json
}

resource "aws_guardduty_detector" "ow_guardduty" {
  enable = true

  datasources {
    s3_logs {
      enable = false
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = false
        }
      }
    }
    kubernetes {
      audit_logs {
        enable = false
      }
    }
  }
}

resource "aws_guardduty_publishing_destination" "findings_bucket" {
  destination_arn = aws_s3_bucket.guardduty.arn
  detector_id     = aws_guardduty_detector.ow_guardduty.id
  kms_key_arn     = aws_kms_key.guardduty_key.arn


  depends_on = [aws_s3_bucket_policy.gd_bucket_policy]

}
