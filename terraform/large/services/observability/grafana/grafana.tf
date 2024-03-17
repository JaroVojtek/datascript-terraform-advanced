data "aws_region" "current" {}

module "grafana-shared-ec1" {
  source = "git::https://github.com/lablabs/tf-infra.git//modules/terraform-aws-eks-grafana?ref=mod-0.78.1"
  #  source = "../../../modules/terraform-aws-eks-grafana"

  context = module.label-shared-ec1.context

  grafana_namespace    = "grafana"
  grafana_release_name = "grafana"

  grafana_cluster_identity_oidc_issuer     = data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer
  grafana_cluster_identity_oidc_issuer_arn = data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer_arn

  # FIXME customer: In case of not using SSO, set grafana_secret_manager_enabled = false and grafana_auth.<provider>.enabled = false
  grafana_secret_manager_enabled = true

  # FIXME customer: update settings for SSO login according to https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/
  grafana_auth = {
    # https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/google/
    "auth.google" = {
      enabled       = true
      scopes        = "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"
      auth_url      = "https://accounts.google.com/o/oauth2/auth"
      token_url     = "https://accounts.google.com/o/oauth2/token"
      allow_sign_up = true
      #FIXME customer: whitelisting domains is optional when Google OAuth consent screen is set to type internal
      # allowed_domains = "lablabs.io"
    }
    # https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/gitlab/
    "auth.gitlab" = {
      enabled       = false
      scopes        = "read_api"
      auth_url      = "https://gitlab.com/oauth/authorize"
      token_url     = "https://gitlab.com/oauth/token"
      api_url       = "https://gitlab.com/api/v4"
      allow_sign_up = true
    }
  }

  # FIXME customer: please increase the replica count to 2 or more in production setup
  grafana_replicas = 2
  grafana_hostname = "grafana.${local.domain_name}"

  # FIXME customer: add all CloudWatch environments
  grafana_cloudwatch_iam_role_arns = [
    module.cloudwatch-shared-ec1.iam_role_arn,
    module.cloudwatch-shared-ec1-prod-ec1.iam_role_arn,
  ]

  #FIXME customer: if enabled, setup SMTP settings, please check module README for ensuring prerequisites and optional parameters.
  grafana_smtp_email_enabled             = true
  grafana_smtp_email_from_address        = "no-reply@acme.org"
  grafana_smtp_user_secrets_manager_name = "ses/smtp_user" # pragma: allowlist secret

  database_create         = true
  database_engine_version = "8.0.mysql_aurora.3.02.2"
  database_external       = false
  # database_external_host = ""
  # database_external_port = 3306
  # database_external_name = ""
  # database_external_san_endpoint = ""
  # database_external_secrets_manager_name = ""

  # FIXME customer: please increase the instance count to 2 or more in production setup
  database_cluster_size = 1
  database_zone_id = [
    data.terraform_remote_state.base.outputs.route53.main_public_zone.id,
    data.terraform_remote_state.base.outputs.route53.main_private_zone[0].id
  ]
  database_vpc_id  = data.terraform_remote_state.base.outputs.vpc.vpc_id
  database_subnets = keys(data.terraform_remote_state.base.outputs.vpc.subnets.service)
  database_security_groups = [
    data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_managed_security_group_id
  ]
  database_allowed_cidr_blocks = [
    data.terraform_remote_state.def.outputs.vpc["shared"][data.aws_region.current.name]["default"]["wireguard_cidr"]
  ]
}
