locals {
  # Required labels
  namespace = "ref"
  name      = "monitoring"
  stage     = "services"

  # Organization tagging strategy labels
  tags = {
    "${local.namespace}:ops:owner"                = "devops"
    "${local.namespace}:ops:project"              = "infra"
    "${local.namespace}:ops:service"              = local.name
    "${local.namespace}:ops:terraform"            = "true"
    "${local.namespace}:ops:terraform-repository" = "tf-infra"
    "${local.namespace}:ops:terraform-path"       = "services/observability/${local.name}"
  }

  root_dns_domain = data.terraform_remote_state.def.outputs.root_dns_name

  # FIXME customer: add all (excluding shared) environments root account ARNs to this list
  prometheus_root_account_arns = [
    "arn:aws:iam::${data.aws_caller_identity.prod-ec1.account_id}:root",
  ]
  # FIXME customer: add all (excluding shared) environments Thanos sidecars hostnames including port to this list
  prometheus_thanos_sidecar_hostnames = [
    "${module.prometheus-prod-ec1.prometheus_thanos_sidecar_hostname}:443",
  ]
  # FIXME customer: remove monitors that are not needed
  prometheus_monitors = [
    "node-problem-detector",
    "ingress-nginx-controller",
    # "ingress-traefik-controller",
    "cert-manager",
    "cilium",
    "vector",
    "loki",
    # kyverno",
  ]

  thanos_release_name = "thanos"
  thanos_common_labels = {
    "monitoring/scope" : "system"
  }
  thanos_common_priority_class_name = "platform-critical"
  thanos_common_node_selector = {
    system   = "default"
    launcher = "karpenter"
  }
  thanos_common_tolerations = [
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
  thanos_common_additional_policies = {
    thanos = aws_iam_policy.thanos-shared-ec1.arn
  }
}
