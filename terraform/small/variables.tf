variable "region" {
  description = "AWS region name (e.g. us-west-2)"
  type        = string
}

variable "profile" {
  description = "AWS profile name (e.g. default)"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC to use (specify this, if you don't want to create new VPC)"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overriden"
  type        = string
  default     = "0.0.0.0/0"
}