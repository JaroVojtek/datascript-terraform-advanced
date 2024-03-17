#!/usr/bin/env bash

set -euo pipefail

function require() {
  if ! command -v "${1}" &>/dev/null; then
    echo "'${1}' is missing, please install it"
    exit 1
  fi
}

if [ -z "${BASH_VERSINFO}" ] || [ -z "${BASH_VERSINFO[0]}" ] || [ ${BASH_VERSINFO[0]} -lt 4 ]; then
  echo "This script requires Bash version >= 4"
  exit 1
fi

require curl

# FIXME customer: change the default Grafana URL to your Grafana instance
read -erp "Enter Grafana URL: " -i "https://grafana.shared-ec1.ref-arch.lablabs.io" GRAFANA_URL
read -erp "Enter Grafana username: " -i "admin" GRAFANA_USERNAME
read -ersp "Enter Grafana password: " GRAFANA_PASSWORD
read -erp "Enter Grafana alert rule UID: " GRAFANA_ALERT_RULE_UID

# See https://grafana.com/docs/grafana/latest/developers/http_api/alerting_provisioning/#route-get-alert-rule
curl -sSfL -u "${GRAFANA_USERNAME}:${GRAFANA_PASSWORD}" "${GRAFANA_URL}/api/v1/provisioning/alert-rules/${GRAFANA_ALERT_RULE_UID}"
