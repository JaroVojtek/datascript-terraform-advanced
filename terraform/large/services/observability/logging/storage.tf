module "loki-shared-ec1-bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

  name    = "loki"
  context = module.label-shared-ec1.context

  versioning_enabled = false
  sse_algorithm      = "aws:kms"
  kms_master_key_arn = module.loki-shared-ec1-bucket-kms.key_arn

  lifecycle_configuration_rules = [
    {
      id      = "expiration"
      enabled = true
      expiration = {
        days = local.log_retention_days
      }
      filter_and                             = {}
      noncurrent_version_expiration          = {}
      transition                             = []
      noncurrent_version_transition          = []
      abort_incomplete_multipart_upload_days = null
    }
  ]

  s3_object_ownership = "BucketOwnerEnforced"
}

module "loki-shared-ec1-bucket-kms" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  name    = "loki"
  context = module.label-shared-ec1.context

  description = "KMS key for Loki bucket"
  policy      = data.aws_iam_policy_document.loki_bucket_kms.json
}
