terraform {
  required_version = "~> 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 1.29.0"
    }
  }
}
