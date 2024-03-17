output "secret_manager_stmp_user_secret_name" {
  description = "The name of the secret in AWS Secrets Manager"
  value       = try(aws_secretsmanager_secret.ses_smtp_user[0].name, "")
}

output "ssm_parameter_name_stmp_user_access_key_id" {
  description = "The name of the parameter in AWS SSM Parameter Store for smtp user access key id"
  value       = try(aws_ssm_parameter.smtp_user_access_key[0].name, "")
}

output "ssm_parameter_name_stmp_user_access_key_secret" {
  description = "The name of the parameter in AWS SSM Parameter Store for smtp user access key secret"
  value       = try(aws_ssm_parameter.smtp_user_secret_access_key[0].name, "")
}
