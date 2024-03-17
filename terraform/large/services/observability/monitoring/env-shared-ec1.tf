module "prometheus-shared-ec1" {
  source = "git::https://github.com/lablabs/tf-infra.git//modules/terraform-aws-eks-prometheus?ref=mod-0.81.1"

  enabled = true

  environment = "shared-ec1"
  context     = module.label.context

  cluster_identity_oidc_issuer     = data.terraform_remote_state.shared-ec1.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = data.terraform_remote_state.shared-ec1.outputs.eks_cluster.eks.eks_cluster_identity_oidc_issuer_arn

  dns_domain_name = local.root_dns_domain

  thanos_bucket_id          = module.thanos-shared-ec1-bucket.bucket_id
  thanos_bucket_region      = module.thanos-shared-ec1-bucket.bucket_region
  thanos_bucket_arn         = module.thanos-shared-ec1-bucket.bucket_arn
  thanos_bucket_kms_key_arn = module.thanos-shared-ec1-bucket-kms.key_arn

  prometheus_monitors = local.prometheus_monitors

  providers = {
    aws        = aws.shared-ec1
    kubernetes = kubernetes.shared-ec1
  }
}

data "aws_caller_identity" "shared-ec1" {
  provider = aws.shared-ec1
}

data "aws_region" "shared-ec1" {
  provider = aws.shared-ec1
}

data "terraform_remote_state" "shared-ec1" {
  backend = "s3"
  config = {
    key            = "env/shared-ec1/base/terraform.tfstate"
    encrypt        = true
    bucket         = "ref-shared-terraform-state"
    dynamodb_table = "ref-shared-terraform-state-lock"
    region         = "eu-central-1"
    profile        = "shared"
  }
}

provider "aws" {
  alias   = "shared-ec1"
  region  = "eu-central-1"
  profile = "shared"
}

provider "kubernetes" {
  alias                  = "shared-ec1"
  host                   = data.terraform_remote_state.shared-ec1.outputs.eks_cluster.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.shared-ec1.outputs.eks_cluster.eks.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.shared-ec1.outputs.eks_cluster.eks.eks_cluster_id, "--profile", "shared", "--region", data.aws_region.shared-ec1.name]
  }
}
