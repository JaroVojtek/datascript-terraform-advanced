module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  # Variable description can be found here: https://github.com/cloudposse/terraform-aws-kms-key
  enabled     = true
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = ["1"]
  tags        = var.tags

  description = "KMS key for S3 encryption"
}

module "s3" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = ["1"]
  tags        = var.tags

  # Lifecycle configuration:
  #   https://registry.terraform.io/providers/hashicorp/aws%20%20/latest/docs/resources/s3_bucket_lifecycle_configuration
  #   https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html
  lifecycle_configuration_rules = var.lifecycle_rules

  # A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket
  versioning_enabled = var.versioning_enabled

  # The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`
  sse_algorithm = "aws:kms"

  # The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`.
  # The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`
  kms_master_key_arn = module.kms_key.key_arn

  # Default BucketOwnerEnforced S3 object ownership disables creation of bucket ACLs.
  # If you require bucket ACLs, modify this value according to https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html
  # https://github.com/cloudposse/terraform-aws-s3-bucket#input_s3_object_ownership
  s3_object_ownership = "BucketOwnerEnforced"
}
