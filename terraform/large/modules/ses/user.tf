resource "aws_iam_user" "ses_smtp_user" {
  #checkov:skip=CKV_AWS_273: IAM SMTP user needs to have console access for email sending
  count = var.create_smtp_user ? 1 : 0
  name  = "${module.label.id}-smtp-user"
  tags  = module.label.tags
}

resource "aws_iam_access_key" "ses_smtp_user" {
  count = var.create_smtp_user ? 1 : 0
  user  = aws_iam_user.ses_smtp_user[0].name
}

resource "aws_ssm_parameter" "smtp_user_access_key" {
  #checkov:skip=CKV_AWS_337: "Allow usage of AWS KMS for encryption of the secret"
  count = var.create_smtp_user ? 1 : 0
  name  = "/smtp_user/ses_send_mails/access_key_id"
  type  = "SecureString"
  value = aws_iam_access_key.ses_smtp_user[0].id
}

resource "aws_ssm_parameter" "smtp_user_secret_access_key" {
  #checkov:skip=CKV_AWS_337: "Allow usage of AWS KMS for encryption of the secret"
  count = var.create_smtp_user ? 1 : 0
  name  = "/smtp_user/ses_send_mails/secret_access_key"
  type  = "SecureString"
  value = aws_iam_access_key.ses_smtp_user[0].ses_smtp_password_v4
}

resource "aws_secretsmanager_secret" "ses_smtp_user" {
  #checkov:skip=CKV2_AWS_57: "Dont require automatic secret rotation"
  #checkov:skip=CKV_AWS_149: "The secret is encrypted by default"
  count       = var.create_smtp_user && var.smtp_user_credentials_to_secrets_manager ? 1 : 0
  name        = "ses/smtp_user"
  description = "SMTP user credetials for SES"
  tags        = module.label.tags
}

resource "aws_secretsmanager_secret_version" "ses_smtp_user" {
  count     = var.create_smtp_user && var.smtp_user_credentials_to_secrets_manager ? 1 : 0
  secret_id = aws_secretsmanager_secret.ses_smtp_user[0].id
  secret_string = jsonencode({
    "username" = aws_iam_access_key.ses_smtp_user[0].id
    "password" = aws_iam_access_key.ses_smtp_user[0].ses_smtp_password_v4
  })
}
