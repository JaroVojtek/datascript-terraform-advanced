terraform {
  backend "s3" {
    key            = "large/services/ecr/terraform.tfstate"
    bucket         = "datascript-terraform-state"
    dynamodb_table = "terraform_state_lock"
    region         = "eu-central-1"
    profile        = "workload"
  }
}

data "terraform_remote_state" "dev" {
  backend = "s3"
  config = {
    key            = "large/dev/base/terraform.tfstate"
    encrypt        = true
    bucket         = "datascript-terraform-state"
    dynamodb_table = "terraform_state_lock"
    region         = "eu-central-1"
    profile        = "workload"
  }
}

data "terraform_remote_state" "prod" {
  backend = "s3"
  config = {
    key            = "large/prod/base/terraform.tfstate"
    encrypt        = true
    bucket         = "datascript-terraform-state"
    dynamodb_table = "terraform_state_lock"
    region         = "eu-central-1"
    profile        = "workload"
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "shared"
}