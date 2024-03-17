data "aws_iam_policy_document" "thanos_bucket_kms" {
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
        "arn:aws:iam::${data.aws_caller_identity.shared-ec1.account_id}:root"
      ]
    }
  }

  statement {
    sid    = "AllowKMSEncryptDecrypt"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    #checkov:skip=CKV_AWS_109
    #checkov:skip=CKV_AWS_356
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = local.prometheus_root_account_arns
    }
  }

  provider = aws.shared-ec1
}

data "aws_iam_policy_document" "thanos-shared-ec1" {
  statement {
    sid    = "AllowThanosObjectStore"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      module.thanos-shared-ec1-bucket.bucket_arn,
      "${module.thanos-shared-ec1-bucket.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowThanosObjectStoreKMS"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [
      module.thanos-shared-ec1-bucket-kms.key_arn
    ]
  }
}

resource "aws_iam_policy" "thanos-shared-ec1" {
  name        = "${module.label-shared-ec1.id}-thanos"
  description = "Thanos policy"
  policy      = data.aws_iam_policy_document.thanos-shared-ec1.json
  tags        = module.label-shared-ec1.tags

  provider = aws.shared-ec1
}
