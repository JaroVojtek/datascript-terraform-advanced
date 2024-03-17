terraform {
  backend "s3" {
    key            = "large/network/terraform.tfstate"
    bucket         = "datascript-terraform-state"
    dynamodb_table = "terraform_state_lock"
    region         = "eu-central-1"
    profile        = "workload"
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    key            = "large/shared/base/terraform.tfstate"
    encrypt        = true
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
  alias   = "shared"
  region  = "eu-central-1"
  profile = "shared"
}

provider "aws" {
  alias   = "workload"
  region  = "eu-central-1"
  profile = "workload"
}


data "aws_region" "shared" {
  provider = aws.shared
}

data "aws_region" "dev" {
  provider = aws.workload
}

data "aws_region" "prod" {
  provider = aws.workload
}
