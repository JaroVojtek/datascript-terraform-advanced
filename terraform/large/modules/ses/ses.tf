resource "aws_ses_email_identity" "ses_email" {
  for_each = toset(var.emails)

  email = each.key
}

resource "aws_ses_domain_identity" "ses_domain" {
  for_each = var.domains

  domain = each.key
}

resource "aws_route53_record" "amazonses_verification_record" {
  for_each = { for k, v in var.domains : k => v if v.verify }

  zone_id = each.value.zone_id
  name    = "_amazonses.${each.key}"
  type    = "TXT"
  ttl     = "600"
  records = [join("", aws_ses_domain_identity.ses_domain[each.key][*].verification_token)]
}

resource "aws_ses_domain_identity_verification" "ses_verification_check" {
  for_each = { for k, v in var.domains : k => v if v.verify }

  domain = each.key

  depends_on = [aws_route53_record.amazonses_verification_record]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  for_each = var.domains

  domain = each.key
}

resource "aws_route53_record" "amazonses_dkim_1_record" {
  for_each = { for k, v in var.domains : k => v if v.dkim_records }

  zone_id = each.value.zone_id
  name    = "${aws_ses_domain_dkim.ses_domain_dkim[each.key].dkim_tokens[0]}._domainkey.${each.key}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.ses_domain_dkim[each.key].dkim_tokens[0]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "amazonses_dkim_2_record" {
  for_each = { for k, v in var.domains : k => v if v.dkim_records }

  zone_id = each.value.zone_id
  name    = "${aws_ses_domain_dkim.ses_domain_dkim[each.key].dkim_tokens[1]}._domainkey.${each.key}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.ses_domain_dkim[each.key].dkim_tokens[1]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "amazonses_dkim_3_record" {
  for_each = { for k, v in var.domains : k => v if v.dkim_records }

  zone_id = each.value.zone_id
  name    = "${aws_ses_domain_dkim.ses_domain_dkim[each.key].dkim_tokens[2]}._domainkey.${each.key}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.ses_domain_dkim[each.key].dkim_tokens[2]}.dkim.amazonses.com"]
}

resource "aws_ses_configuration_set" "ses_configuration_set" {
  for_each = var.create_configuration_set ? var.config_sets : {}
  name     = "${module.label.id}-${each.key}-conf-set"

  delivery_options {
    tls_policy = each.value.tls_policy
  }

  reputation_metrics_enabled = each.value.reputation_metrics_enabled
  sending_enabled            = each.value.sending_enabled
}

resource "aws_ses_event_destination" "email_events_destination" {
  for_each               = var.create_ses_sns_event_destinations ? var.ses_sns_event_destinations : {}
  name                   = "${module.label.id}-${each.key}-event-dest"
  configuration_set_name = aws_ses_configuration_set.ses_configuration_set[each.value.configuration_set_name].name
  enabled                = true
  matching_types         = each.value.event_destination_matching_types

  sns_destination {
    topic_arn = each.value.sns_destination_name != null ? aws_sns_topic.ses_email_events[each.value.sns_destination_name].arn : null
  }
}
