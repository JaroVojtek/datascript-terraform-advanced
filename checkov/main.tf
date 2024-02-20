resource "aws_s3_bucket" "bucket-name" {
  # checkov:skip=CKV_AWS_144 Do not require S3 bucket cross-region replication
  bucket = "my-unique-bucket-name"
  acl    = "private"
}

resource "aws_iam_policy" "bad_example" {
  name        = "overly_permissive_policy"
  description = "An overly permissive policy."
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "*",
    "Resource": "*",
    "Effect": "Allow"
  }]
}
EOF
}

resource "aws_iam_role" "bad_example" {
  name = "too_permissive_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

resource "aws_kms_key" "bad_example" {
  description             = "KMS key 1"
  enable_key_rotation     = false
}

resource "aws_secretsmanager_secret" "bad_example" {
  name                    = "example_secret"
  kms_key_id              = "alias/aws/secretsmanager" # Default AWS managed key
}