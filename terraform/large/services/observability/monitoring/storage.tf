module "thanos-shared-ec1-bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

  name    = "thanos"
  context = module.label-shared-ec1.context

  versioning_enabled = false
  sse_algorithm      = "aws:kms"
  kms_master_key_arn = module.thanos-shared-ec1-bucket-kms.key_arn
  privileged_principal_actions = [
    "s3:ListBucket",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:PutObject",
    "s3:PutObjectAcl"
  ]
  privileged_principal_arns = [
    for account in local.prometheus_root_account_arns : { (account) = [""] }
  ]

  s3_object_ownership = "BucketOwnerEnforced"

  providers = {
    aws = aws.shared-ec1
  }
}

module "thanos-shared-ec1-bucket-kms" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  name    = "thanos"
  context = module.label-shared-ec1.context

  description = "KMS key for thanos bucket"
  policy      = data.aws_iam_policy_document.thanos_bucket_kms.json

  providers = {
    aws = aws.shared-ec1
  }
}
