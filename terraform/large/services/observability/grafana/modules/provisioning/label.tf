module "label-grafana" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  tags        = var.tags
  attributes  = var.attributes
  context     = var.context
}

module "label-aws" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = var.context
}
