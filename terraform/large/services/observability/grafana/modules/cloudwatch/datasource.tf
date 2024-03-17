data "aws_region" "current" {}

resource "grafana_data_source" "cloudwatch" {
  uid  = "cloudwatch-${module.label.environment}"
  name = "CloudWatch - ${module.label.environment}"
  type = "cloudwatch"

  json_data_encoded = jsonencode({
    defaultRegion = data.aws_region.current.name
    authType      = "default"
    assumeRoleArn = aws_iam_role.this.arn
  })
}
