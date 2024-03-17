locals {
  # Required labels
  account   = "shared"
  namespace = "ref"
  name      = "logging"
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

  loki_common_labels = {
    "monitoring/scope" = "system"
  }
  loki_common_node_selector = {
    system   = "default"
    launcher = "karpenter"
  }
  loki_common_tolerations = [
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
