locals {
  # load alerts from a file
  alerts = {
    for alert in fileset("${path.root}/alerts", "**/*.json") : alert => jsondecode(
      file("${path.root}/alerts/${alert}")
    )
  }

  # normalize alerts setting the folder and group
  alerts_normalized = {
    for alert, rule in local.alerts : alert => {
      group_id   = format("%s/%s", dirname(alert), rule.ruleGroup)
      folder_uid = var.alert_folders[dirname(alert)].uid
      group_name = rule.ruleGroup
      rule       = rule
    }
  }

  # merge alerts under the same folder and group
  rule_groups = {
    for group, rules in { for k, v in local.alerts_normalized : v.group_id => v... } : group => {
      name       = rules[0].group_name
      folder_uid = rules[0].folder_uid
      rules      = rules[*].rule
    }
  }
}

module "rule-groups" {
  source = "git::https://github.com/lablabs/tf-infra.git//modules/terraform-aws-eks-grafana-rule-groups?ref=mod-0.63.2"
  #  source = "../../../../../modules/terraform-aws-eks-grafana-rule-groups"

  context = module.label.context

  secrets_manager_enabled = false
  hostname                = var.grafana_hostname
  auth                    = var.grafana_auth

  rule_groups = local.rule_groups
}
