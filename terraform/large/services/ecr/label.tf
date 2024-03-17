module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = local.namespace
  environment = local.environment
  stage       = local.stage
  tags        = local.tags
}
