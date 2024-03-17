data "terraform_remote_state" "def" {
  backend = "s3"

  config = {
    key            = "network/definition/terraform.tfstate"
    encrypt        = true
    bucket         = "ref-management-terraform-state"
    dynamodb_table = "ref-management-terraform-state-lock"
    region         = "eu-central-1"
    profile        = "delegated-management"
  }
}

data "terraform_remote_state" "base" {
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

terraform {
  backend "s3" {
    key            = "services/observability/grafana/terraform.tfstate"
    encrypt        = true
    bucket         = "ref-shared-terraform-state"
    dynamodb_table = "ref-shared-terraform-state-lock"
    region         = "eu-central-1"
    profile        = "shared"
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "shared"
}

provider "aws" {
  alias   = "prod-ec1"
  region  = "eu-central-1"
  profile = "prod"
}

provider "grafana" {
  url  = "https://${module.grafana-shared-ec1.hostname}"
  auth = "${module.grafana-shared-ec1.admin_user}:${module.grafana-shared-ec1.admin_password}"
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.base.outputs.eks_cluster.eks.eks_cluster_id, "--profile", local.account]
  }
}
