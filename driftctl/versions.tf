#driftctl scan --from tfstate+s3://twintag-engineering-s3-bucket-statefile-bootstrap-xgfs353xfg54/terraform.tfstate --filter $'(Type==\'aws_s3_bucket\') && !(Type==\'aws_s3_bucket\' && starts_with(Id, \'twintag-\'))'

terraform {
  required_version = "~> 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
  
  backend "s3" {

    bucket         = "twintag-engineering-s3-bucket-statefile-bootstrap-xgfs353xfg54"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform_state_lock"
    profile        = "default"
  }
}