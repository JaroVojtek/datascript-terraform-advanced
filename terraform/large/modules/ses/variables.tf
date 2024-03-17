variable "emails" {
  description = "List o email identities to be created in SES service"
  default     = []
  type        = list(string)
}

variable "domains" {
  description = "List of domains for which to create SES domain identities"
  default     = {}
  type = map(object({
    zone_id             = string
    verify              = bool
    dkim_records        = bool
    send_policy_enabled = bool
    send_identities     = optional(list(string))
  }))
}

variable "create_smtp_user" {
  description = "Create IAM SMTP user for email sending"
  type        = bool
  default     = false
}

variable "smtp_user_credentials_to_secrets_manager" {
  description = "Wheter to store SMTP user credentials to Secrets Manager or not"
  type        = bool
  default     = false
}

variable "smtp_user_ses_policy_additional_resources" {
  description = "Additional IAM policy resources to which SMTP user can send mails"
  type        = list(string)
  default     = []
}

variable "create_configuration_set" {
  description = "Wheter to create SES configuration set or not"
  type        = bool
  default     = false
}

variable "config_sets" {
  description = "Configuration object for SES configuration sets"
  type = map(object({
    tls_policy                 = string
    reputation_metrics_enabled = bool
    sending_enabled            = bool
  }))
}

variable "create_ses_sns_event_destinations" {
  description = "Wheter to create SES event destinations or not"
  type        = bool
  default     = false
}

variable "ses_sns_event_destinations" {
  description = "Configuration of Event destination for SES configuration set"
  type = map(object({
    configuration_set_name           = string
    event_destination_matching_types = list(string)
    sns_destination_name             = string
  }))

  validation {
    condition     = alltrue([for event_destination in var.ses_sns_event_destinations : alltrue([for type in event_destination["event_destination_matching_types"] : contains(["send", "reject", "bounce", "complaint", "delivery", "open", "click", "renderingFailure"], type)])])
    error_message = "Supported event destination matching types are \"send\", \"reject\", \"bounce\", \"complaint\", \"delivery\", \"open\", \"click\", or \"renderingFailure\"."
  }


}

variable "create_ses_sns_topics" {
  description = "Wheter to create SNS topics for SES email events or not"
  type        = bool
  default     = false
}

variable "ses_sns_topics" {
  description = "SNS topic configuration"
  type = map(object({
    subscribe_to_sqs = bool
  }))
}
