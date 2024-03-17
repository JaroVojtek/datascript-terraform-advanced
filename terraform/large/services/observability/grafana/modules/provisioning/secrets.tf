resource "aws_secretsmanager_secret" "provisioning" {
  #checkov:skip=CKV2_AWS_57: "Dont require automatic secret rotation"
  #checkov:skip=CKV_AWS_149: "The secret is encrypted by default"
  name        = "grafana/${module.label-aws.id}/provisioning"
  description = "Grafana provisioning secrets"
  tags        = module.label-grafana.tags
}

resource "aws_secretsmanager_secret_version" "provisioning" {
  secret_id = aws_secretsmanager_secret.provisioning.id

  secret_string = jsonencode({
    hostname = var.grafana_hostname
    api-key  = grafana_service_account_token.provisioning.key
  })
}
