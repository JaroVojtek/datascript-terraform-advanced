module "label-shared-ec1" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = local.namespace
  environment = "shared-ec1"
  stage       = local.stage
  name        = local.name
  tags = merge(local.tags, {
    "${local.namespace}:ops:environment" = "shared-ec1"
  })
}
