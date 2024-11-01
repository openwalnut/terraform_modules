# AWS VPC Terraform Module

This Terraform module creates a customizable Virtual Private Cloud (VPC) in AWS. It includes public and private subnets, an internet gateway, NAT gateway, and necessary routing, all configurable via input variables.

## Features

- Creates a VPC with customizable CIDR block
- Configurable public and private subnets across multiple availability zones
- Internet Gateway for public subnets
- NAT Gateway for private subnets, allowing internet access for instances in private subnets
- Routing tables for public and private subnets

## Usage

### Requirements

- Terraform >= 0.12
- AWS credentials configured

### Example

```hcl
module "vpc" {
  source              = "./vpc_module" # Update with the actual path to your module
  vpc_cidr_block      = "172.20.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b"]
  public_subnets_cidr = ["172.20.48.0/20", "172.20.64.0/20"]
  private_subnets_cidr = ["172.20.0.0/20", "172.20.16.0/20"]

  public_subnets = {
    a = "172.20.32.0/20"
    b = "172.20.48.0/20"
  }

  private_subnets = {
    a = "172.20.0.0/20"
    b = "172.20.16.0/20"
  }
}
```

### Input Variables

| Variable              | Description                          | Type        | Default                                             |
|-----------------------|--------------------------------------|-------------|-----------------------------------------------------|
| `vpc_cidr_block`      | CIDR block for the VPC              | `string`    | `"172.20.0.0/16"`                                   |
| `availability_zones`  | List of availability zones          | `list(string)` | `["us-east-1a", "us-east-1b"]`                  |
| `public_subnets_cidr` | List of CIDR blocks for public subnets | `list(string)` | `["172.20.48.0/20", "172.20.64.0/20"]`          |
| `private_subnets_cidr`| List of CIDR blocks for private subnets | `list(string)` | `["172.20.0.0/20", "172.20.16.0/20"]`           |
| `public_subnets`      | Public subnets mapped to AZs        | `map(string)` | `{a = "172.20.32.0/20", b = "172.20.48.0/20"}`  |
| `private_subnets`     | Private subnets mapped to AZs       | `map(string)` | `{a = "172.20.0.0/20", b = "172.20.16.0/20"}`   |

## Outputs

| Output               | Description                               |
|----------------------|-------------------------------------------|
| `vpc_id`             | The ID of the created VPC                |
| `public_subnet_ids`  | The IDs of the public subnets            |
| `private_subnet_ids` | The IDs of the private subnets           |
| `nat_gateway_ids`    | The IDs of the NAT Gateways              |
| `internet_gateway_id`| The ID of the Internet Gateway           |

## Usage

To use this module, copy and paste the following code into your Terraform configuration file. Adjust the variable values as needed.

```hcl
module "vpc" {
  source               = "./modules/vpc"  # Update this to your module path
  vpc_cidr_block       = "172.20.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnets_cidr  = ["172.20.48.0/20", "172.20.64.0/20"]
  private_subnets_cidr = ["172.20.0.0/20", "172.20.16.0/20"]
  public_subnets       = { a = "172.20.32.0/20", b = "172.20.48.0/20" }
  private_subnets      = { a = "172.20.0.0/20", b = "172.20.16.0/20" }
}
```

## Requirements

| Name        | Version |
|-------------|---------|
| `terraform` | >= 0.12 |
| `aws`       | >= 2.70 |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 2.70 |


