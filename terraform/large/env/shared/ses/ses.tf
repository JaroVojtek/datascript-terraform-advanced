module "ses" {
  source = "../../../modules/ses"

  namespace   = local.namespace
  environment = local.environment
  stage       = local.stage
  name        = local.name
  attributes  = [""]
  tags        = local.tags

  emails = ["jaroslav.vojtek90@gmail.com"]

  domains = {
    (data.terraform_remote_state.shared.outputs.public_root_zone_name) = {
      zone_id             = data.terraform_remote_state.shared.outputs.public_root_zone_id
      verify              = true
      dkim_records        = true
      send_policy_enabled = false
    }
  }
  create_smtp_user                          = true
  smtp_user_credentials_to_secrets_manager  = true
  smtp_user_ses_policy_additional_resources = []

  # NOTE: It is possible to set default configuration set for SES identity only via management console
  create_configuration_set = false
  config_sets = {
    "default" = {
      tls_policy                 = "Require"
      reputation_metrics_enabled = false
      sending_enabled            = true
    }
  }

  create_ses_sns_event_destinations = false
  ses_sns_event_destinations = {
    "sns-publish" = {
      configuration_set_name           = "default"
      event_destination_matching_types = ["reject", "bounce", "complaint", "delivery", "renderingFailure"]
      sns_destination_name             = "email-events"
    }
  }

  create_ses_sns_topics = false
  ses_sns_topics = {
    "email-events" = {
      subscribe_to_sqs = true
    }
  }
}
