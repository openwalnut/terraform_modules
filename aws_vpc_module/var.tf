variable "vpc_cidr_block" {
  description = "CIRD ranges for VPC"
  type        = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "Public Subnet CIDRs"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "Private Subnet CIDRs"
}

variable "public_subnets" {
  type        = map(string)
  description = "Public subnets used in VPC mapped to AZ letter"
}

variable "private_subnets" {
  type        = map(string)
  description = "Private subnets used in VPC mapped to AZ letter"
}

