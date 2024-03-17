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