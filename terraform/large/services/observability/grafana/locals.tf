locals {
  # Required labels
  account   = "shared"
  namespace = "ref"
  name      = "grafana"
  stage     = "services"

  # Organization tagging strategy labels
  tags = {
    "${local.namespace}:ops:owner"                = "devops"
    "${local.namespace}:ops:project"              = "infra"
    "${local.namespace}:ops:service"              = local.name
    "${local.namespace}:ops:terraform"            = "true"
    "${local.namespace}:ops:terraform-repository" = "tf-infra"
    "${local.namespace}:ops:terraform-path"       = "${local.stage}/observability/${local.name}"
  }

  domain_name = data.terraform_remote_state.base.outputs.route53.main_private_zone[0].name
}
