data "aws_iam_policy_document" "loki_bucket_kms" {
  #checkov:skip=CKV_AWS_356: allow "*" for kms key policy
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
data "aws_iam_policy_document" "loki_shared_ec1" {
  statement {
    sid    = "AllowLokiObjectStore"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      module.loki-shared-ec1-bucket.bucket_arn,
      "${module.loki-shared-ec1-bucket.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "AllowLokiObjectStoreKMS"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [
      module.loki-shared-ec1-bucket-kms.key_arn
    ]
  }

  statement {
    sid    = "AllowLokiDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:ListTagsOfResource",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable",
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/loki_index_*"
    ]
  }

  statement {
    sid    = "AllowLokiDynamoDBlistTables"
    effect = "Allow"
    actions = [
      "dynamodb:ListTables"
    ]
    #checkov:skip=CKV_AWS_109
    resources = ["*"]
  }
}

resource "aws_iam_policy" "loki_shared_ec1" {
  name        = "${module.label-shared-ec1.id}-loki"
  description = "Custom Loki IAM policy"
  policy      = data.aws_iam_policy_document.loki_shared_ec1.json
  tags        = module.label-shared-ec1.tags
}
