terraform {
    backend "s3" {
    bucket         = "datascript-terraform-state"
    key            = "large/dev/base/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform_state_lock"
    profile        = "workload"
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

provider "aws" {
  profile = var.profile
  region  = var.region
  default_tags {
    tags = merge({
      "Provisioner" = "Terraform"
      "Owner"       = "Datascript"
    }, 
    var.tags)
  }
}