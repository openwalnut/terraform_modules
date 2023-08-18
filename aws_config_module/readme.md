# AWS Config and Controls Terraform Module

This Terraform module sets up AWS Config resources for monitoring and controlling your AWS environment. It creates an S3 bucket for storing configuration data, an SNS topic for receiving notifications, an AWS Config delivery channel, and an AWS Config rule.

## Usage

1. Clone or copy this repository to your local machine.

2. Modify the variables in your main configuration file (e.g., `main.tf`) to match your requirements.

   ```hcl
   module "my_config" {
     source                = "./aws_config_module"
     bucket_name           = "unique-bucket-name"   # Modify this
     sns_topic_name        = "my-topic"             # Modify this
     delivery_channel_name = "my-delivery-channel"  # Modify this
     config_rule_name      = "my-config-rule"       # Modify this
   }

   ```

3. Run terraform init to initialize your configuration.

4. Run terraform plan to see the planned changes before applying.

5. Run terraform apply to create the AWS resources.

## Variables

`bucket_name`: Name for the S3 bucket (globally unique).

`sns_topic_name`: Name for the SNS topic (within your AWS account).

`delivery_channel_name`: Name for the AWS Config delivery channel (within your AWS account).

`config_rule_name`: Name for the AWS Config rule (within your AWS account).

## Outputs

`bucket_name`: Name of the created S3 bucket.

`sns_topic_name`: Name of the created SNS topic.

`delivery_channel_name`: Name of the created AWS Config delivery channel.

`config_rule_name`: Name of the created AWS Config rule.

Feel free to modify the variable values according to your naming conventions and requirements.

For more information on Terraform and AWS Config, consult the official documentation:

- [Terraform Documentation](https://developer.hashicorp.com/terraform/tutorials)
- [AWS Config Documentation](https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html)
