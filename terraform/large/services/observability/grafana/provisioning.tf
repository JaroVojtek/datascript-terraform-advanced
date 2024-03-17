module "provisioning-shared-ec1" {
  source = "./modules/provisioning"

  context = module.label-shared-ec1.context

  grafana_hostname = module.grafana-shared-ec1.hostname
}

module "provisioning-shared-ec1-prod-ec1" {
  source = "./modules/provisioning"

  environment = "prod-ec1"
  context     = module.label-shared-ec1.context

  grafana_hostname = module.grafana-shared-ec1.hostname

  providers = {
    aws = aws.prod-ec1
  }
}
