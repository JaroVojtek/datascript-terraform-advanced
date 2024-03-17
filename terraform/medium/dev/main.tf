locals {
  create_vpc = var.vpc_name != ""
}

module "vpc" {
  count = local.create_vpc ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.owner}-${var.environment}-${var.vpc_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = false

  tags = var.tags
}

module "s3" {
  source = "../modules/s3"

  namespace   = var.owner
  environment = var.region
  stage       = var.environment
  name        = "s3"
  tags        = var.tags
  
  versioning_enabled = false

  lifecycle_rules = [{
    enabled = false
    id      = "default" # string, must be specified and unique

    abort_incomplete_multipart_upload_days = null # number
    filter_and = {
      object_size_greater_than = null # integer >= 0
      object_size_less_than    = null # integer >= 1
      prefix                   = null # string
      tags                     = {}   # map(string)
    }
    expiration = {
      date                         = null # string
      days                         = 90   # integer > 0
      expired_object_delete_marker = null # bool
    }
    noncurrent_version_expiration = {
      newer_noncurrent_versions = null # integer > 0
      noncurrent_days           = null # integer >= 0
    }
    transition = [{
      date          = null          # string
      days          = 30            # integer >= 0
      storage_class = "STANDARD_IA" # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    }]
    noncurrent_version_transition = [{
      newer_noncurrent_versions = null # integer >= 0
      noncurrent_days           = null # integer >= 0
      storage_class             = null # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
    }]
  }]
}
