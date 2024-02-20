config {

  format = "compact"

  call_module_type = "local"
  force = false
  disabled_by_default = false

  ignore_module = {}

  varfile = []
  variables = []
}

plugin "terraform" {
    enabled = true
    version = "0.5.0"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

plugin "aws" {
    enabled = true
    version = "0.30.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

#Rule sets https://github.com/terraform-linters/tflint-ruleset-terraform/blob/main/docs/rules/README.md

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true

  source = true
  version = true
}