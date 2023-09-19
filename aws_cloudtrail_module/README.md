# Terraform CloudTrail Encryption Module

This Terraform module creates and configures the necessary resources for creating CloudTrail Trail, encrypting CloudTrail logs using a Key Management Service (KMS) key and storing them in an S3 bucket with server-side encryption enabled. It also sets up the required IAM roles and policies for CloudTrail and CloudWatch Logs integration.

## Usage

1. **Clone or Copy the Module**

   Clone or copy this module to your local machine or include it from a source repository.

2. **Modify Input Variables**

   Update the input variables in your main Terraform configuration file (e.g., `main.tf`) to match your specific requirements:

   ```hcl
   module "cloudtrail_encryption" {
     source               = "./path/to/module" # Replace with the actual path or module source
     kms_key_description  = "KMS key for CloudTrail logs encryption"
     s3_bucket_name       = "cloudtrail-logs-bucket"
     cloudtrail_trail_name = "my-cloudtrail-trail"
     cloudtrail_role_name = "my-cloudtrail-role"
     cloudwatch_log_group_name = "my-cloudwatch-log-group"
   }


3. Run `terraform init`` to initialize your configuration.

4. Run `terraform plan`` to see the planned changes before applying.

5. Run `terraform apply`` to create the AWS resources.

## Input Variables

- `kms_key_description` (string): Description for the KMS key.
- `s3_bucket_name` (string): Name of the S3 bucket where CloudTrail logs will be securely stored.
- `cloudtrail_trail_name` (string): Name your CloudTrail trail.
- `cloudtrail_role_name` (string): Define a name for the IAM role that CloudTrail will use.
- `cloudwatch_log_group_name` (string): Specify a name for the CloudWatch Log Group for CloudTrail logs.

Feel free to modify the variable values according to your naming conventions and requirements.

## Outputs

Retrieve useful information about your resources:

- `kms_key_arn` (string): The ARN of the created KMS key.
- `s3_bucket_arn` (string): The ARN of the created S3 bucket.
- `cloudtrail_role_arn` (string): The ARN of the IAM role for CloudTrail.
- `cloudwatch_log_group_arn` (string): The ARN of the CloudWatch Log Group for CloudTrail logs.
- `cloudtrail_name` (string): The name of the created CloudTrail trail.

These outputs allow you to access important resource identifiers and names for further configuration and monitoring.