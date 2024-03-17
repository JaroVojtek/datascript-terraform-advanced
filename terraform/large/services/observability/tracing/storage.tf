module "tempo-shared-ec1-bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

  name    = "tempo"
  context = module.label-shared-ec1.context

  versioning_enabled = false
  sse_algorithm      = "aws:kms"
  kms_master_key_arn = module.tempo-shared-ec1-bucket-kms.key_arn

  lifecycle_configuration_rules = [
    {
      id      = "expiration"
      enabled = true
      expiration = {
        days = local.retention_days
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

module "tempo-shared-ec1-bucket-kms" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  name    = "tempo"
  context = module.label-shared-ec1.context

  description = "KMS key for Tempo bucket"
  policy      = data.aws_iam_policy_document.tempo_bucket_kms.json
}
