variable "region" {
  description = "AWS region name (e.g. us-west-2)"
  type        = string
}

variable "profile" {
  description = "AWS profile name (e.g. default)"
  type        = string
}

variable "tags" {
  description = "Environment tags for the resources"
  type        = map(string)
}

variable "environment" {
  description = "Environment name (e.g. dev, qa, prod)"
  type        = string
}

variable "owner" {
  description = "Owner of the infrastructure (e.g. Cloud Team)"
  type        = string
}

variable "vpc_name" {
  description = "A vpc name"
  type        = string
}

variable "vpc_cidr" {
  description = "A vpc cidr block"
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnets in the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets in the VPC"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Single NAT Gateway for all private subnets"
  type        = bool
}
