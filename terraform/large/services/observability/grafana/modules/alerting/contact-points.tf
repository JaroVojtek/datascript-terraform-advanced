resource "grafana_contact_point" "contact_points" {
  for_each = var.contact_points

  name = each.key

  dynamic "googlechat" {
    for_each = lookup(each.value, "googlechat", null) != null ? [true] : []

    content {
      url      = each.value.googlechat.url
      message  = lookup(each.value.googlechat, "message", null)
      settings = lookup(each.value.googlechat, "settings", {})
    }
  }

  dynamic "slack" {
    for_each = lookup(each.value, "slack", null) != null ? [true] : []

    content {
      token           = lookup(each.value.slack, "token", null)
      recipient       = lookup(each.value.slack, "recipient", null)
      title           = lookup(each.value.slack, "title", null)
      text            = lookup(each.value.slack, "text", null)
      mention_channel = lookup(each.value.slack, "mention_channel", null)
      mention_groups  = lookup(each.value.slack, "mention_groups", null)
      mention_users   = lookup(each.value.slack, "mention_users", null)
      username        = lookup(each.value.slack, "username", null)
      icon_emoji      = lookup(each.value.slack, "icon_emoji", null)
      icon_url        = lookup(each.value.slack, "icon_url", null)
      url             = lookup(each.value.slack, "url", null)
      endpoint_url    = lookup(each.value.slack, "endpoint_url", null)
      settings        = lookup(each.value.slack, "settings", {})
    }
  }

  dynamic "teams" {
    for_each = lookup(each.value, "teams", null) != null ? [true] : []

    content {
      url           = each.value.teams.url
      section_title = lookup(each.value.teams, "section_title", null)
      title         = lookup(each.value.teams, "title", null)
      message       = lookup(each.value.teams, "message", null)
      settings      = lookup(each.value.teams, "settings", {})
    }
  }

  dynamic "email" {
    for_each = lookup(each.value, "email", null) != null ? [true] : []

    content {
      addresses = each.value.email.addresses
      subject   = lookup(each.value.email, "subject", null)
      message   = lookup(each.value.email, "message", null)
      settings  = lookup(each.value.email, "settings", {})
    }
  }
}
