resource "grafana_notification_policy" "notification_policy" {
  count = length(var.notification_policy) > 0 ? 1 : 0

  contact_point = grafana_contact_point.contact_points[var.notification_policy.contact_point].name
  group_by      = lookup(var.notification_policy, "group_by", ["..."])

  group_wait      = lookup(var.notification_policy, "group_wait", null)
  group_interval  = lookup(var.notification_policy, "group_interval", null)
  repeat_interval = lookup(var.notification_policy, "repeat_interval", null)

  dynamic "policy" {
    for_each = lookup(var.notification_policy, "policies", [])

    content {
      dynamic "matcher" {
        for_each = lookup(policy.value, "matchers", [])

        content {
          label = matcher.value.label
          match = matcher.value.match
          value = matcher.value.value
        }
      }

      contact_point = grafana_contact_point.contact_points[policy.value.contact_point].name
      group_by      = lookup(policy.value, "group_by", ["..."])

      mute_timings    = lookup(policy.value, "mute_timings", null) != null ? [for mt in policy.value.mute_timings : grafana_mute_timing.mute_timings[mt].name] : []
      group_wait      = lookup(policy.value, "group_wait", null)
      group_interval  = lookup(policy.value, "group_interval", null)
      repeat_interval = lookup(policy.value, "repeat_interval", null)
      continue        = lookup(policy.value, "continue", true)

      dynamic "policy" { # Terraform seems to supports up to 3 nested policies, UI unlimited
        for_each = lookup(policy.value, "policies", [])

        content {
          dynamic "matcher" {
            for_each = lookup(policy.value, "matchers", [])

            content {
              label = matcher.value.label
              match = matcher.value.match
              value = matcher.value.value
            }
          }

          contact_point = grafana_contact_point.contact_points[policy.value.contact_point].name
          group_by      = lookup(policy.value, "group_by", ["..."])

          mute_timings    = lookup(policy.value, "mute_timings", null) != null ? [for mt in policy.value.mute_timings : grafana_mute_timing.mute_timings[mt].name] : []
          group_wait      = lookup(policy.value, "group_wait", null)
          group_interval  = lookup(policy.value, "group_interval", null)
          repeat_interval = lookup(policy.value, "repeat_interval", null)
          continue        = lookup(policy.value, "continue", true)

          dynamic "policy" {
            for_each = lookup(policy.value, "policies", [])

            content {
              dynamic "matcher" {
                for_each = lookup(policy.value, "matchers", [])

                content {
                  label = matcher.value.label
                  match = matcher.value.match
                  value = matcher.value.value
                }
              }

              contact_point = grafana_contact_point.contact_points[policy.value.contact_point].name
              group_by      = lookup(policy.value, "group_by", ["..."])

              mute_timings    = lookup(policy.value, "mute_timings", null) != null ? [for mt in policy.value.mute_timings : grafana_mute_timing.mute_timings[mt].name] : []
              group_wait      = lookup(policy.value, "group_wait", null)
              group_interval  = lookup(policy.value, "group_interval", null)
              repeat_interval = lookup(policy.value, "repeat_interval", null)
              continue        = lookup(policy.value, "continue", true)

              dynamic "policy" {
                for_each = lookup(policy.value, "policies", [])

                content {
                  dynamic "matcher" {
                    for_each = lookup(policy.value, "matchers", [])

                    content {
                      label = matcher.value.label
                      match = matcher.value.match
                      value = matcher.value.value
                    }
                  }

                  contact_point = grafana_contact_point.contact_points[policy.value.contact_point].name
                  group_by      = lookup(policy.value, "group_by", ["..."])

                  mute_timings    = lookup(policy.value, "mute_timings", null) != null ? [for mt in policy.value.mute_timings : grafana_mute_timing.mute_timings[mt].name] : []
                  group_wait      = lookup(policy.value, "group_wait", null)
                  group_interval  = lookup(policy.value, "group_interval", null)
                  repeat_interval = lookup(policy.value, "repeat_interval", null)
                  continue        = lookup(policy.value, "continue", true)
                }
              }
            }
          }
        }
      }
    }
  }
}
