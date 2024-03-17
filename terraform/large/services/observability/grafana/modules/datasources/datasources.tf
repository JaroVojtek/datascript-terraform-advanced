resource "grafana_data_source" "datasources" {
  for_each = {
    for k, v in var.datasources : k => v if lookup(v, "enabled", false)
  }

  uid                      = each.key
  name                     = each.value.name
  type                     = each.value.type
  url                      = lookup(each.value, "url", "")
  json_data_encoded        = lookup(each.value, "json_data_encoded", null)
  secure_json_data_encoded = lookup(each.value, "secure_json_data_encoded", null)
  access_mode              = lookup(each.value, "access", "proxy")
  is_default               = lookup(each.value, "default", false)
  username                 = lookup(each.value, "username", "")
}
