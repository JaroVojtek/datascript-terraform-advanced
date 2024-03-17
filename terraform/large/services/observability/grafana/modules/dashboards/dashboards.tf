resource "grafana_dashboard" "dashboards" {
  for_each = {
    for dashboard in fileset("${path.root}/dashboards", "**/*.json") : dashboard => {
      folder      = var.folders[dirname(dashboard)].id
      config_json = file("${path.root}/dashboards/${dashboard}")
    }
  }

  folder      = each.value.folder
  config_json = each.value.config_json
  overwrite   = true
}
