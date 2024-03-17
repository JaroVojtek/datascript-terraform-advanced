module "ses_example" {
  source = "../"

  namespace   = local.namespace
  environment = local.environment
  stage       = local.stage
  name        = local.name
  attributes  = [""]
  tags        = local.tags

  emails = ["example_user@example_domain.com"]

  domains = {
    "${data.terraform_remote_state.dns.outputs.public_root_zone_name}" = {
      zone_id             = "${data.terraform_remote_state.dns.outputs.public_root_zone_id}"
      verify              = true
      dkim_records        = true
      send_policy_enabled = false
    }
  }
  create_smtp_user                          = true
  smtp_user_ses_policy_additional_resources = []

  # NOTE: It is possible to set default configuration set for SES identity only via management console
  create_configuration_set = true
  config_sets = {
    "default" = {
      tls_policy                 = "Require"
      reputation_metrics_enabled = false
      sending_enabled            = true
    }
  }

  create_ses_sns_event_destinations = true
  ses_sns_event_destinations = {
    "sns-publish" = {
      configuration_set_name           = "default"
      event_destination_matching_types = ["reject", "bounce", "complaint", "delivery", "renderingFailure"]
      sns_destination_name             = "email-events"
    }
  }

  create_ses_sns_topics = true
  ses_sns_topics = {
    "email-events" = {
      subscribe_to_sqs = true
    }
  }
}
