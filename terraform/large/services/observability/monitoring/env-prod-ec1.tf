module "prometheus-prod-ec1" {
  source = "git::https://github.com/lablabs/tf-infra.git//modules/terraform-aws-eks-prometheus?ref=mod-0.81.1"

  enabled = true

  environment = "prod-ec1"
  context     = module.label.context

  cluster_identity_oidc_issuer     = data.terraform_remote_state.prod-ec1.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = data.terraform_remote_state.prod-ec1.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer_arn

  dns_domain_name = local.root_dns_domain

  thanos_bucket_id          = module.thanos-shared-ec1-bucket.bucket_id
  thanos_bucket_region      = module.thanos-shared-ec1-bucket.bucket_region
  thanos_bucket_arn         = module.thanos-shared-ec1-bucket.bucket_arn
  thanos_bucket_kms_key_arn = module.thanos-shared-ec1-bucket-kms.key_arn

  prometheus_monitors = local.prometheus_monitors

  providers = {
    aws        = aws.prod-ec1
    kubernetes = kubernetes.prod-ec1
  }
}

module "prometheus-exporters-prod-ec1" {
  source = "git::https://github.com/lablabs/tf-infra.git//modules/terraform-aws-prometheus-exporters?ref=mod-0.77.0"

  environment = "prod-ec1"
  context     = module.label.context

  cluster_identity_oidc_issuer     = data.terraform_remote_state.prod-ec1.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = data.terraform_remote_state.prod-ec1.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer_arn

  # FIXME customer: add exporter if RabbitMQ is used
  exporters = {
    # "prometheus-rabbitmq-exporter" = {
    #   exporter           = "rabbitmq"
    #   enabled            = true
    #   helm_chart_version = "1.5.0"
    #   values = yamlencode({
    #     "image" : {
    #       "tag" : "1.0.0-RC19"
    #     }
    #     "additionalLabels" : {
    #       "monitoring/scope" : "system"
    #     }
    #     "podLabels" : {
    #       "monitoring/scope" : "system"
    #     }
    #     "nodeSelector" : {
    #       "system" : "default"
    #       "launcher" : "karpenter"
    #     }
    #     "tolerations" = [
    #       {
    #         "key" : "system"
    #         "operator" : "Equal"
    #         "value" : "default"
    #         "effect" : "NoExecute"
    #       },
    #       {
    #         "key" : "launcher"
    #         "operator" : "Equal"
    #         "value" : "karpenter"
    #         "effect" : "NoExecute"
    #       }
    #     ]
    #     "rabbitmq" : {
    #       "url" : data.terraform_remote_state.rabbitmq_prod-ec1.outputs.mq.primary_console_url
    #       "user" : data.terraform_remote_state.rabbitmq_prod-ec1.outputs.mq.application_username
    #       "existingPasswordSecret" : "prometheus-rabbitmq-exporter"
    #       "existingPasswordSecretKey" : "password"
    #     }
    #     "prometheus" : {
    #       "monitor" : {
    #         "enabled" : true
    #         "interval" : "15s"
    #         "relabelings" : [{
    #           sourceLabels : ["cluster"]
    #           targetLabel : "rabbitmq_cluster"
    #         }]
    #       }
    #     }
    #   })
    #   external_secrets = {
    #     enabled = true
    #     name    = "prometheus-rabbitmq-exporter"
    #     type    = "ParameterStore"
    #     data = [{
    #       "secretKey" : "password"
    #       "remoteRef" : {
    #         "key" : data.terraform_remote_state.rabbitmq_prod-ec1.outputs.mq.application_password
    #       }
    #     }]
    #   }
    # }
  }

  # FIXME customer: add SSM parameter if RabbitMQ is used
  irsa_allowed_ssm = {
    # "prometheus-rabbitmq-exporter" : data.terraform_remote_state.rabbitmq_prod-ec1.outputs.mq.application_password
  }

  providers = {
    aws        = aws.prod-ec1
    kubernetes = kubernetes.prod-ec1
  }
}

data "aws_caller_identity" "prod-ec1" {
  provider = aws.prod-ec1
}

data "aws_region" "prod-ec1" {
  provider = aws.prod-ec1
}

data "terraform_remote_state" "prod-ec1" {
  backend = "s3"
  config = {
    key            = "env/prod-ec1/base/terraform.tfstate"
    encrypt        = true
    bucket         = "ref-prod-terraform-state"
    dynamodb_table = "ref-prod-terraform-state-lock"
    region         = "eu-central-1"
    profile        = "prod"
  }
}

# FIXME customer: add remote state if RabbitMQ is used
# data "terraform_remote_state" "rabbitmq_prod-ec1" {
#   backend = "s3"
#   config = {
#     key            = "env/prod-ec1/service/rabbitmq/terraform.tfstate"
#     encrypt        = true
#     bucket         = "ref-prod-terraform-state"
#     dynamodb_table = "ref-prod-terraform-state-lock"
#     region         = "eu-central-1"
#     profile        = "prod"
#   }
# }

provider "aws" {
  alias   = "prod-ec1"
  region  = "eu-central-1"
  profile = "prod"
}

provider "kubernetes" {
  alias                  = "prod-ec1"
  host                   = data.terraform_remote_state.prod-ec1.outputs.eks_cluster.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.prod-ec1.outputs.eks_cluster.eks.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.prod-ec1.outputs.eks_cluster.eks.eks_cluster_id, "--profile", "prod", "--region", data.aws_region.prod-ec1.name]
  }
}
