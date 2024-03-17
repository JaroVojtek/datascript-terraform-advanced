variable "grafana_hostname" {
  type        = string
  description = "The hostname to use for the Grafana instance provisioning"
}

variable "grafana_auth" {
  type        = string
  description = "The auth string to use for the Grafana instance provisioning"
  sensitive   = true
}

variable "contact_points" {
  type        = any
  default     = {}
  description = "Alerting contact points. Currently only supports slack, googlechat and teams"
}

variable "message_templates" {
  type        = map(string)
  default     = {}
  description = "Alerting message templates. Keys are the template name, values are the template content"
}

variable "mute_timings" {
  type        = any
  default     = {}
  description = "Alerting mute timings"
}

variable "notification_policy" {
  type        = any
  default     = {}
  description = "Alerting notification policy. This will replace the default notification policy"
}

variable "alert_folders" {
  type        = map(any)
  description = "A map of Grafana folders to create alerts from. Key is the folder path, value is the grafana_folder resource outputs"
}
