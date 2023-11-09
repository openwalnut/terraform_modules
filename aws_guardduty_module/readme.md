# AWS GuardDuty Terraform Module

The Terraform GuardDuty AWS Module is designed to simplify the configuration and setup of AWS GuardDuty, a managed threat detection service that continuously monitors your AWS accounts for malicious or unauthorized activity. This module encapsulates the creation of resources required for GuardDuty, including an S3 bucket, S3 bucket policy, KMS key, and GuardDuty detector.

## Usage

1. Clone or copy this repository to your local machine.

2. Modify the variables in your main configuration file (e.g., `main.tf`) to match your requirements.

   ```hcl
   module "my_config" {
     source                = "./aws_config_module"
     bucket_name           = "unique-bucket-name"   # Modify this
   }

   ```

3. Run terraform init to initialize your configuration.

4. Run terraform plan to see the planned changes before applying.

5. Run terraform apply to create the AWS resources.

## Variables

`bucket_name`: Name for the S3 bucket (globally unique).

## Outputs

`bucket_name`: Name of the created S3 bucket.


Feel free to modify the variable values according to your naming conventions and requirements.

For more information on Terraform and AWS GuardDuty, consult the official documentation:

- [Terraform Documentation](https://developer.hashicorp.com/terraform/tutorials)
- [AWS GuardDuty Documentation](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html)
