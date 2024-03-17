data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "send_mails" {
  for_each = { for k, v in var.domains : k => v if v.send_policy_enabled }

  statement {
    sid = "SednMails_${each.key}"

    effect = "Allow"

    resources = [aws_ses_domain_identity.ses_domain[each.key].arn]

    actions = ["SES:Send*"]

    principals {
      type        = "AWS"
      identifiers = each.value.send_identities
    }
  }
}

resource "aws_ses_identity_policy" "send_mails" {
  for_each = { for k, v in var.domains : k => v if v.send_policy_enabled }
  identity = aws_ses_domain_identity.ses_domain[each.key].arn
  name     = "${module.label.id}-send-mails"
  policy   = data.aws_iam_policy_document.send_mails[each.key].json
}

data "aws_iam_policy_document" "smtp_user_ses_policy" {
  count = var.create_smtp_user ? 1 : 0
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = concat(
      [for k in aws_ses_domain_identity.ses_domain : k.arn],
      [for k in aws_ses_email_identity.ses_email : k.arn],
      var.smtp_user_ses_policy_additional_resources
    )
  }
}

resource "aws_iam_policy" "smtp_user_ses_policy" {
  count       = var.create_smtp_user ? 1 : 0
  name        = "${module.label.id}-smtp-user-ses-policy"
  description = "Allows sending e-mails via SES for IAM SMTP user"
  policy      = data.aws_iam_policy_document.smtp_user_ses_policy[0].json
}

resource "aws_iam_user_policy_attachment" "smtp_user_ses_policy_attachment" {
  #checkov:skip=CKV_AWS_40: Allow attach IAM policy directly to user
  count      = var.create_smtp_user ? 1 : 0
  user       = aws_iam_user.ses_smtp_user[0].name
  policy_arn = aws_iam_policy.smtp_user_ses_policy[0].arn
}

data "aws_iam_policy_document" "sns_topic_policy" {
  for_each = var.create_ses_sns_topics ? { for sns_topics in aws_sns_topic.ses_email_events : sns_topics.name => sns_topics.arn } : {}
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    resources = [each.value]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "allow_access" {
  for_each = var.create_ses_sns_topics ? { for sns_topics in aws_sns_topic.ses_email_events : sns_topics.name => sns_topics.arn } : {}

  arn    = each.value
  policy = data.aws_iam_policy_document.sns_topic_policy[each.key].json
}

data "aws_iam_policy_document" "sns_kms_policy" {
  #checkov:skip=CKV_AWS_109: Allow root and ses service to use kms key
  #checkov:skip=CKV_AWS_111: Allow root and ses service to use kms key
  #checkov:skip=CKV_AWS_356: Allow "kms:*" actions"
  statement {
    sid    = "Enable the account that owns the KMS key to manage it via IAM"
    effect = "Allow"

    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
      ]
    }
  }

  statement {
    sid = "AllowSESToUseKMSKey"

    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    resources = ["*"]
  }
}
