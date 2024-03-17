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

terraform {
  backend "s3" {
    key            = "services/observability/monitoring/terraform.tfstate"
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
