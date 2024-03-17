locals {
  namespace = var.namespace != null ? var.namespace : try(var.context.namespace, "")
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.namespace
  stage       = var.stage
  environment = var.environment
  name        = var.name
  attributes  = var.attributes
  context     = var.context
  tags = merge(
    var.tags,
    { "${local.namespace}:ops:terraform-module" = "terraform-aws-ses" }
  )
}
