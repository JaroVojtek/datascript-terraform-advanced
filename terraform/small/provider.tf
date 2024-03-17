terraform {
  backend "s3" {
    bucket         = "datascript-terraform-state"
    key            = "small/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform_state_lock"
    profile        = "workload"
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}