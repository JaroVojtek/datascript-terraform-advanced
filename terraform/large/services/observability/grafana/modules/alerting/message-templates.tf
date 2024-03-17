resource "grafana_message_template" "message_templates" {
  for_each = var.message_templates

  name     = each.key
  template = each.value
}
