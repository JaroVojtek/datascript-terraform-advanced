resource "grafana_service_account" "provisioning" {
  name = "grafana-provisioning-${module.label-grafana.environment}"
  role = "Admin"
}

resource "grafana_service_account_token" "provisioning" {
  name               = grafana_service_account.provisioning.name
  service_account_id = grafana_service_account.provisioning.id
}
