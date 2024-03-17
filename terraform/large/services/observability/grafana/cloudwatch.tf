module "cloudwatch-shared-ec1" {
  source = "./modules/cloudwatch"

  context = module.label-shared-ec1.context

  grafana_iam_role_arn = module.grafana-shared-ec1.iam_role_arn
}

module "cloudwatch-shared-ec1-prod-ec1" {
  source = "./modules/cloudwatch"

  environment = "prod-ec1"
  context     = module.label-shared-ec1.context

  grafana_iam_role_arn = module.grafana-shared-ec1.iam_role_arn

  providers = {
    aws = aws.prod-ec1
  }
}
