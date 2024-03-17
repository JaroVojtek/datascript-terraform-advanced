locals {
  account     = "prod"
  namespace   = "ref"
  environment = "${local.account}-ec1"
  stage       = "service"
  name        = "s3"

  tags = {
    "${local.namespace}:ops:owner"                = "devops"
    "${local.namespace}:ops:project"              = "infra"
    "${local.namespace}:ops:service"              = local.name
    "${local.namespace}:ops:environment"          = local.environment
    "${local.namespace}:ops:terraform"            = "true"
    "${local.namespace}:ops:terraform-repository" = "tf-infra"
    "${local.namespace}:ops:terraform-path"       = "env/${local.environment}/service/${local.name}"
  }
}
