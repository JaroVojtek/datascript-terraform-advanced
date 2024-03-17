resource "grafana_mute_timing" "mute_timings" {
  for_each = var.mute_timings

  name = each.key

  intervals {
    dynamic "times" {
      for_each = lookup(each.value, "times", null) != null ? [true] : []

      content {
        start = each.value.times.start
        end   = each.value.times.end
      }
    }
    weekdays      = lookup(each.value, "weekdays", [])
    days_of_month = lookup(each.value, "days_of_month", [])
    months        = lookup(each.value, "months", [])
    years         = lookup(each.value, "years", [])
  }
}
