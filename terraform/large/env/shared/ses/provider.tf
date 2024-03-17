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

terraform {
  backend "s3" {
    key            = "large/shared/ses/terraform.tfstate"
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
