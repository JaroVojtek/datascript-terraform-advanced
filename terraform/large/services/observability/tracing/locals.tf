locals {
  # Required labels
  account   = "shared"
  namespace = "ref"
  name      = "tracing"
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

  tempo_common_node_selector = {
    system   = "default"
    launcher = "karpenter"
  }
  tempo_common_tolerations = [
    {
      key      = "system"
      operator = "Equal"
      value    = "default"
      effect   = "NoSchedule"
    },
    {
      key      = "launcher"
      operator = "Equal"
      value    = "karpenter"
      effect   = "NoSchedule"
    }
  ]
}
