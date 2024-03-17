module "label-shared-ec1" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = local.namespace
  environment = "shared"
  stage       = local.stage
  tags = merge(
    local.tags,
    {
      "${local.namespace}:ops:environment" = "shared"
    }
  )
}
