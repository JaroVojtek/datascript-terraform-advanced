output "service_account_name" {
  description = "The Grafana provisioning service account name"
  value       = grafana_service_account.provisioning.name
}

output "service_account_api_key" {
  description = "The Grafana provisioning service account API key"
  value       = grafana_service_account_token.provisioning.key
  sensitive   = true
}

output "secret_manager_name" {
  description = "The name of the secret with provisioning details in the Secrets Manager"
  value       = aws_secretsmanager_secret.provisioning.name
}
