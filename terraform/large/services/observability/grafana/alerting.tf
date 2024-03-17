data "aws_secretsmanager_secret" "grafana_shared_ec1" { # workaround for https://github.com/grafana/grafana/issues/54984 which is closed, but not fixed, remove once fixed
  count = module.grafana-shared-ec1.secrets_manager_enabled ? 1 : 0

  name = module.grafana-shared-ec1.secrets_manager_name
}

data "aws_secretsmanager_secret_version" "grafana_shared_ec1" { # workaround for https://github.com/grafana/grafana/issues/54984 which is closed, but not fixed, remove once fixed
  count = module.grafana-shared-ec1.secrets_manager_enabled ? 1 : 0

  secret_id = data.aws_secretsmanager_secret.grafana_shared_ec1[0].id
}

module "alerting-shared-ec1" {
  source = "./modules/alerting"

  context = module.label-shared-ec1.context

  grafana_hostname = module.grafana-shared-ec1.hostname
  grafana_auth     = "${module.grafana-shared-ec1.admin_user}:${module.grafana-shared-ec1.admin_password}"

  # FIXME customer: change to the customer needs
  # https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point
  # https://grafana.com/docs/grafana/latest/alerting/set-up/provision-alerting-resources/file-provisioning/#provision-contact-points
  contact_points = {
    default = {
      slack = {                                                                                                                            # for a list of available options, see `modules/alerting/contact_points.tf#dynamic.slack`
        token     = jsondecode(data.aws_secretsmanager_secret_version.grafana_shared_ec1[0].secret_string)["GF_CONTACT_POINT_SLACK_TOKEN"] # Slack App oAuth token, used when sending message via API https://api.slack.com/messaging/sending
        recipient = "lablabs-aws-reference-arch-alerts"                                                                                    # Slack channel, used when sending message via API https://api.slack.com/messaging/sending
        # url   = jsondecode(data.aws_secretsmanager_secret_version.grafana_shared_ec1[0].secret_string)["GF_CONTACT_POINT_SLACK_WEBHOOK_URL"] # Incoming webhook URL, if uncommented, token and recipient are not necessary https://api.slack.com/messaging/webhooks
        title = "{{ template \"slack.title\" . }}" # optional, using default template defined in the message_templates map below
        text  = "{{ template \"slack.text\" . }}"  # optional, using default template defined in the message_templates map below
      }
    }
    #    default = {
    #      googlechat = {                                                                                                                     # for a list of available options, see `modules/alerting/contact_points.tf#dynamic.googlechat`
    #        url = jsondecode(data.aws_secretsmanager_secret_version.grafana_shared_ec1[0].secret_string)["GF_CONTACT_POINT_GOOGLE_CHAT_URL"] # Google Chat Webhook URL
    #      }
    #    }
    #    default = {
    #      teams = {                                                                                                                    # for a list of available options, see `modules/alerting/contact_points.tf#dynamic.teams`
    #        url = jsondecode(data.aws_secretsmanager_secret_version.grafana_shared_ec1[0].secret_string)["GF_CONTACT_POINT_TEAMS_URL"] # Microsoft Teams Webhook URL
    #      }
    #    }
    #    default = {
    #      email = {                        # for a list of available options, see `modules/alerting/contact_points.tf#dynamic.email`
    #        addresses = ["email@acme.org"]
    #      }
    #    }
  }

  # FIXME customer: change to the customer needs
  # https://grafana.com/docs/grafana/latest/alerting/contact-points/message-templating
  message_templates = {
    slack = <<-EOF
      {{ define "slack.title.prefix" }}
      {{- if ne .Status "firing" -}}
        :white_check_mark:
      {{- else if eq .CommonLabels.severity "critical" -}}
        :red_circle:
      {{- else if eq .CommonLabels.severity "warning" -}}
        :warning:
      {{- end -}}
      {{ end }}

      {{ define "slack.title" }}
      {{ template "slack.title.prefix" . }} [{{- .Status | toUpper -}}{{- if eq .Status "firing" }} x {{ .Alerts.Firing | len -}}{{- end -}}] {{ .CommonLabels.grafana_folder }} > {{ .CommonLabels.alertname }}
      {{ end }}

      {{ define "slack.text" }}
      {{- range .Alerts }}
      {{ if gt (len .Annotations) 0 }}
      {{- if .Annotations.summary }}
      *Summary*: {{ .Annotations.summary }}
      {{- end }}
      {{- if .Annotations.description }}
      *Description*: {{ .Annotations.description }}
      {{- end }}
      {{ end }}
      {{- if gt (len .GeneratorURL ) 0 }}
      *Grafana*: <{{ .GeneratorURL }}|:fire:>
      {{- end }}
      {{- if gt (len .DashboardURL ) 0 }}
      *Dashboard:* <{{ .DashboardURL }}|:control_knobs:>
      {{- end }}
      {{- if gt (len .PanelURL ) 0 }}
      *Panel:* <{{ .PanelURL }}|:bar_chart:>
      {{- end }}
      {{- if gt (len .Annotations) 0 }}
      {{- if .Annotations.runbook_url }}
      *Runbook*: <{{ .Annotations.runbook_url }}|:hammer:>
      {{- end }}
      {{- end }}
      {{- if gt (len .SilenceURL ) 0 }}
      *Silence alert:*  <{{ .SilenceURL }}|:no_bell:>
      {{- end }}
      {{ if gt (len .Labels) 0 }}
      Labels:
      {{- range .Labels.SortedPairs }}
        • {{ .Name }}: `{{ .Value }}`
      {{- end }}
      {{ end }}
      {{- end }}
      {{ end }}
    EOF
  }

  # FIXME customer: change to the customer needs
  # https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/mute_timing
  #  mute_timings = {
  #    weekend = {
  #      weekdays = ["saturday", "sunday"]
  #    }
  #  }

  # FIXME customer: change to the customer needs
  # https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/notification_policy
  notification_policy = {
    contact_point   = "default" # key from contact_points map
    group_by        = ["grafana_folder", "alertname"]
    group_wait      = "30s"
    group_interval  = "5m"
    repeat_interval = "1h"
  }

  alert_folders = module.folders-shared-ec1.folders
}
