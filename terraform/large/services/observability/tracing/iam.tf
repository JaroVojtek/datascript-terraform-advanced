data "aws_iam_policy_document" "tempo_bucket_kms" {
  statement {
    sid    = "AllowFullKMS"
    effect = "Allow"
    #checkov:skip=CKV_AWS_111
    actions = [
      "kms:*"
    ]
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_356
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
}
data "aws_iam_policy_document" "tempo_shared_ec1" {
  statement {
    sid    = "AllowTempoObjectStore"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = [
      module.tempo-shared-ec1-bucket.bucket_arn,
      "${module.tempo-shared-ec1-bucket.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowTempoObjectStoreKMS"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [
      module.tempo-shared-ec1-bucket-kms.key_arn
    ]
  }
}

resource "aws_iam_policy" "tempo_shared_ec1" {
  name        = "${module.label-shared-ec1.id}-tempo"
  description = "Custom Tempo IAM policy"
  policy      = data.aws_iam_policy_document.tempo_shared_ec1.json
  tags        = module.label-shared-ec1.tags
}
